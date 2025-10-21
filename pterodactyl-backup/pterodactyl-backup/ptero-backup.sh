#!/bin/bash

# -------------------------------
# SETTINGS
# -------------------------------
BACKUP_DIR="/root/ptero-backups"            # VPS backup folder
PTERO_SRV_DIR="/var/lib/pterodactyl/volumes" # Pterodactyl servers path
GDRIVE_FOLDER="gdrive:/PteroBackups"        # Google Drive folder
RETENTION_DAYS=7                             # Delete backups older than 7 days

mkdir -p "$BACKUP_DIR"

# Timestamp
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

# Loop through all servers
for SERVER in "$PTERO_SRV_DIR"/*; do
    if [ -d "$SERVER" ]; then
        SERVER_NAME=$(basename "$SERVER")
        BACKUP_FILE="$BACKUP_DIR/${SERVER_NAME}_$TIMESTAMP.tar.gz"

        echo "Backing up $SERVER_NAME..."
        tar -czf "$BACKUP_FILE" -C "$PTERO_SRV_DIR" "$SERVER_NAME"

        echo "Uploading $SERVER_NAME backup to Google Drive..."
        rclone copy "$BACKUP_FILE" "$GDRIVE_FOLDER"
    fi
done

# Delete old backups from VPS
find "$BACKUP_DIR" -type f -mtime +$RETENTION_DAYS -name "*.tar.gz" -exec rm {} \;

echo "Backup completed at $TIMESTAMP"
