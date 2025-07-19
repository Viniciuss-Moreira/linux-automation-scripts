TEMPLATES_DIR="$(dirname "$0")/../config/user_templates"
LOG_DIR="/var/log/user_manager"
CONF_TPL="$(dirname "$0")/../config/backup.conf"  # mesmo ini usado como exemplo
mkdir -p "$LOG_DIR"

log() {
    echo "[$(date +'%F %T')] $*" >> "$LOG_DIR/user_manager.log"
}

gen_pass() {
    tr -dc 'A-Za-z0-9!@#$%^&*()_+=' </dev/urandom | head -c 12
}

add_user() {
    local user="$1"
    local pass=$(gen_pass)
    local profile=$(awk -F' *= *' '/^\[templates\]/{f=1;next}/\[/{f=0} f && $1=="default"{print $2;exit}' "$CONF_TPL")
    useradd -m -s /bin/bash "$user"
    echo "$user:$pass" | chpasswd
    mkdir -p "$LOG_DIR/archive"
    echo "$pass" > "$LOG_DIR/$user.creds"
    log "ADD $user profile=$profile"
    # aplicar templates
    if [[ -d "$TEMPLATES_DIR/$profile" ]]; then
        cp -r "$TEMPLATES_DIR/$profile/." "/home/$user/"
        chown -R "$user:$user" "/home/$user/"
    fi
    usermod -aG sudo "$user"
    echo "Usuário $user criado com senha em $LOG_DIR/$user.creds"
}

del_user() {
    local user="$1"
    log "DEL_START $user"
    usermod -L "$user"
    timestamp=$(date +%Y%m%d%H%M)
    mv "/home/$user" "$LOG_DIR/archive/${user}_$timestamp"
    userdel "$user"
    log "DEL_DONE $user"
    echo "Usuário $user removido com home em $LOG_DIR/archive/${user}_$timestamp"
}

case "$1" in
    add) add_user "$2" ;;
    del) del_user "$2" ;;
    *) echo "Uso: $0 {add|del} username" ;;
esac
