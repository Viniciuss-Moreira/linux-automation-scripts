CONFIG="$(dirname "$0")/../config/log_cleaner.conf"

get_conf() {
    local section="$1" key="$2"
    awk -F' *= *' "/^\[$section\]/ {f=1; next} /^\[/{f=0} f && \$1==\"$key\" {print \$2; exit}" "$CONFIG"
}

IFS=',' read -r -a DIRS <<< "$(get_conf general log_dirs)"
IFS=',' read -r -a EXTS <<< "$(get_conf general extensions)"
MAX_AGE="$(get_conf general max_age_days)"
MIN_SIZE="$(get_conf general min_size_kb)"
IFS=',' read -r -a PRESERVE <<< "$(get_conf general preserve_patterns)"
CMP_EN="$(get_conf compression enabled)"
CMP_M="$(get_conf compression method)"
REPORT="$(eval echo $(get_conf report report_file))"
SHOW_SPACE="$(get_conf report show_space)"

mkdir -p "$(dirname "$REPORT")"

log_removed=()
log_compressed=()
space_before=0
space_after=0

(( SHOW_SPACE == "true" )) && space_before=$(du -sb ${DIRS[*]} | awk '{print $1}')

for dir in "${DIRS[@]}"; do
    find "$dir" -type f \( $(printf -- "-iname '*.%s' -o " "${EXTS[@]}" | sed 's/ -o $//') \) -print0 \
    | while IFS= read -r -d '' file; do
        for pat in "${PRESERVE[@]}"; do
            [[ "$file" =~ $pat ]] && continue 2
        done
        age=$(expr $(date +%s) - $(stat -c %Y "$file"))
        days=$(( age/86400 ))
        size_kb=$(( $(stat -c %s "$file")/1024 ))
        if (( days > MAX_AGE )); then
            rm -f "$file"
            log_removed+=("$file")
        elif (( CMP_EN == "true" && size_kb > MIN_SIZE )); then
            case "$CMP_M" in
                gzip)  gzip -f "$file"     && log_compressed+=("$file.gz");;
                bzip2) bzip2 -f "$file"    && log_compressed+=("$file.bz2");;
                xz)    xz -f "$file"       && log_compressed+=("$file.xz");;
            esac
        fi
    done
done

(( SHOW_SPACE == "true" )) && space_after=$(du -sb ${DIRS[*]} | awk '{print $1}')

{
    echo "Log Cleaner Report - $(date +%F\ %T)"
    echo ""
    echo "Arquivos Removidos:"
    printf " - %s\n" "${log_removed[@]}"
    echo ""
    echo "Arquivos Comprimidos:"
    printf " - %s\n" "${log_compressed[@]}"
    if (( SHOW_SPACE == "true" )); then
        freed=$(( space_before - space_after ))
        echo ""
        echo "Espaço Liberado: $((freed/1024)) KB"
    fi
} > "$REPORT"