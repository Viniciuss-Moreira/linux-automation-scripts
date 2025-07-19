CONFIG="$(dirname "$0")/../config/backup.conf"

get_conf() {
    local section="$1" key="$2"
    awk -F' *= *' "/^\[$section\]/ {found=1; next} /^\[/{found=0} found && \$1==\"$key\" {print \$2; exit}" "$CONFIG"
}

IFS=',' read -r -a SOURCES <<< "$(get_conf general source_dirs)"
BACKUP_DIR="$(get_conf general backup_dir)"
DATE_FMT="$(get_conf general date_format)"
MODE="$(get_conf general mode)"
RET_DAYS="$(get_conf general retention_days)"
COMP="$(get_conf general compression)"
MAX_FULL="$(get_conf rotation max_full_backups)"
MAX_INC="$(get_conf rotation max_incrementals)"
EMAIL_ENABLED="$(get_conf email enabled)"
EMAIL_TO="$(get_conf email to)"
SMTP_SERVER="$(get_conf email smtp_server)"
SMTP_USER="$(get_conf email smtp_user)"
SMTP_PASS="$(get_conf email smtp_pass)"
LOG_FILE="$(get_conf logging log_file)"
LOG_LEVEL="$(get_conf logging log_level)"

mkdir -p "$BACKUP_DIR" "$(dirname "$LOG_FILE")"
exec &> >(tee -a "$LOG_FILE")

log() {
    local lvl="$1" msg="$2"
    [[ "$lvl" == "DEBUG" && "$LOG_LEVEL" != "DEBUG" ]] && return
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] [$lvl] $msg"
}

send_mail() {
    local subject="$1" body="$2"
    if [[ "$EMAIL_ENABLED" == "true" ]]; then
        printf "Subject: %s\n\n%s\n" "$subject" "$body" \
        | curl --url "smtp://${SMTP_SERVER}" \
                --mail-from "${SMTP_USER}" \
                --mail-rcpt "${EMAIL_TO}" \
                --upload-file - \
                --user "${SMTP_USER}:${SMTP_PASS}" &>/dev/null \
        && log INFO "Email enviado para $EMAIL_TO" \
        || log ERROR "Falha ao enviar email"
    fi
}

# Determina nome do backup
TS=$(date +"$DATE_FMT")
if [[ "$MODE" == "full" ]]; then
    target="$BACKUP_DIR/full-$TS.tar"
else
    # incremental: aponta para último full
    last_full=$(ls -1t "$BACKUP_DIR"/full-*.tar 2>/dev/null | head -n1)
    if [[ -z "$last_full" ]]; then
        log WARN "Nenhum backup full encontrado, executando full"
        MODE="full"
        target="$BACKUP_DIR/full-$TS.tar"
    else
        inc_dir="$BACKUP_DIR/inc-$TS"
        mkdir -p "$inc_dir"
        for src in "${SOURCES[@]}"; do
            rsync -a --link-dest="$last_full" "$src" "$inc_dir/"
        done
        tar -cf "$BACKUP_DIR/inc-$TS.tar" -C "$BACKUP_DIR" "inc-$TS"
        rm -rf "$inc_dir"
        target="$BACKUP_DIR/inc-$TS.tar"
    fi
fi

case "$COMP" in
    gzip)  gzip -f "$target"   && target="$target.gz";;
    bzip2) bzip2 -f "$target"  && target="$target.bz2";;
    xz)    xz -f "$target"     && target="$target.xz";;
esac

log INFO "Backup ($MODE) criado: $target"

# Rotação de backups completos
if [[ "$MODE" == "full" ]]; then
    keep=$(ls -1t "$BACKUP_DIR"/full-* | head -n"$MAX_FULL")
    for f in "$BACKUP_DIR"/full-*; do
        [[ " ${keep[*]} " =~ " $f " ]] || { rm -f "$f"; log INFO "Removido old full: $f"; }
    done
fi

for full in $(ls -1t "$BACKUP_DIR"/full-*); do
    incs=( $(ls -1t "$BACKUP_DIR"/inc-*.tar* 2>/dev/null) )
    idx=0
    for inc in "${incs[@]}"; do
        if [[ $idx -ge $MAX_INC ]]; then
            rm -f "$inc"
            log INFO "Removido old incremental: $inc"
        fi
        ((idx++))
    done
done

BODY="Backup $MODE gerado em $target\nLogs em $LOG_FILE"
send_mail "Relatório de Backup: $TS" "$BODY"
