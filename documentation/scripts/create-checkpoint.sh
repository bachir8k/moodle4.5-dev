#!/bin/bash

# Generate a timestamp
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

echo "Creating checkpoint with timestamp: $TIMESTAMP"

# --- Backup Configuration Files ---
echo "Backing up configuration files..."
cp docker-compose.yml backups-lcl/configs/docker-compose.yml.$TIMESTAMP
cp nginx/default.conf backups-lcl/configs/nginx-default.conf.$TIMESTAMP
cp php/Dockerfile backups-lcl/configs/php-Dockerfile.$TIMESTAMP
cp php/custom.ini backups-lcl/configs/php-custom.ini.$TIMESTAMP
echo "Configuration files backed up."

# --- Backup Database ---
echo "Backing up PostgreSQL database..."
docker-compose exec -T moodle4.5-db pg_dump -U moodle45 -d moodle45 > backups-lcl/moodle-db-backup.$TIMESTAMP.sql
echo "Database backup complete."

# --- Backup Moodle Data ---
echo "Backing up moodledata directory..."
docker-compose exec -T moodle4.5-php tar -czf - /var/www/moodledata > backups-lcl/moodledata-backup.$TIMESTAMP.tar.gz
echo "Moodle data backup complete."

echo "Checkpoint created successfully."

# --- Enforce Retention Policy ---
echo "Enforcing retention policy (keeping last 3 backups)..."

# Database backups
ls -1t backups-lcl/moodle-db-backup.*.sql 2>/dev/null | tail -n +4 | xargs -I {} rm -- {}
echo "Cleaned up old database backups."

# Moodledata backups
ls -1t backups-lcl/moodledata-backup.*.tar.gz 2>/dev/null | tail -n +4 | xargs -I {} rm -- {}
echo "Cleaned up old moodledata backups."