BACKUP_DIR="/var/backups"
SOURCE_DIR="/home"
DATE=$(date +%F)

mkdir -p $BACKUP_DIR
tar -czf $BACKUP_DIR/backup-$DATE.tar.gz $SOURCE_DIR

echo "Backup concluído em $BACKUP_DIR/backup-$DATE.tar.gz"