# Operations Guide

This document outlines standard operational procedures for managing the Moodle environment, such as synchronizing data between local and server environments.

## Syncing Environments (Local to Server)

To make a server environment (like the VPS) an exact clone of your local development environment, you need to synchronize two key components: the database and the `moodledata` directory.

This is a manual process that involves backing up the data from the source (local machine) and restoring it on the target (server).

**IMPORTANT:** Always ensure the Moodle codebase in your Git repository is complete and deployed on the target server *before* attempting to sync data.

### 1. Migrating the Database

The database contains all course structure, settings, user information, grades, and forum posts.

1.  **Export Local Database:** Create a compressed SQL dump of your local PostgreSQL database. You can do this by executing the following command against your local `moodle-db` container:
    ```bash
    docker-compose exec -T moodle-db pg_dump -U moodle -d moodle | gzip > moodle-database.sql.gz
    ```
2.  **Transfer Backup:** Securely transfer the `moodle-database.sql.gz` file to your target server.
3.  **Import to Server Database:**
    *   First, drop the existing database on the server to ensure a clean import.
    *   Then, import the backup file into the server's PostgreSQL container.
    ```bash
    # Example commands to be run on the server
    docker-compose exec -T moodle-db dropdb -U moodle moodle
    docker-compose exec -T moodle-db createdb -U moodle moodle
    gunzip < moodle-database.sql.gz | docker-compose exec -T moodle-db psql -U moodle -d moodle
    ```

### 2. Migrating the `moodledata` Directory

The `moodledata` directory contains all user-uploaded files, course materials (videos, images, documents), and other site-generated data.

1.  **Backup Local `moodledata`:** Create a compressed archive of your local `moodledata` volume.
    ```bash
    # This command runs a temporary container to access the volume and create a backup.
    docker run --rm --volumes-from moodle-php -v $(pwd):/backup ubuntu tar czvf /backup/moodledata-backup.tar.gz /var/www/moodledata
    ```
2.  **Transfer Backup:** Securely transfer the `moodledata-backup.tar.gz` file to your target server.
3.  **Restore on Server:**
    *   First, ensure the existing `moodledata` directory on the server is empty.
    *   Then, extract the backup into the server's `moodledata` volume.
    ```bash
    # Example commands to be run on the server
    # 1. Remove existing data
    docker run --rm --volumes-from moodle-php -v $(pwd):/backup ubuntu rm -rf /var/www/moodledata/*
    # 2. Extract new data
    docker run --rm --volumes-from moodle-php -v $(pwd):/backup ubuntu tar xzvf /backup/moodledata-backup.tar.gz -C /
    # 3. Fix permissions
    docker-compose exec moodle-php chown -R www-data:www-data /var/www/moodledata
    ```

### 3. Final Steps

After restoring both the database and `moodledata`, you may need to:

*   **Update `config.php`:** Ensure the `$CFG->wwwroot` and other server-specific settings in the server's `config.php` are correct.
*   **Purge Caches:** Log in to your Moodle site as an administrator and purge all caches to ensure all changes are reflected.
