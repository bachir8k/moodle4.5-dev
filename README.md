# Moodle 4.5 Project

This file contains project-specific information and documentation for the Moodle 4.5 environment.

## Documentation

*   [Installation Guide](documentation/installation.md)
*   [Configuration Guide](documentation/configuration.md)
*   [Features Log](documentation/features.md)
*   [Plugins List](documentation/plugins.md)

## Version Control

This directory is a self-contained Git repository. To perform Git operations from the project root, use the `git-45.bat` wrapper script.

*   **Example:** `git-45 status`

## Checkpoints

This project uses a checkpoint system to save and restore the state of the database and `moodledata` directory. The scripts are located in `documentation/scripts/`.

*   **To Create a Checkpoint:**
    ```bash
    ./documentation/scripts/create-checkpoint.sh
    ```
*   **Retention Policy:** The creation script automatically keeps the **3 most recent** checkpoints and deletes older ones.

*   **To Restore from a Checkpoint:**
    ```bash
    ./documentation/scripts/restore-from-checkpoint.sh
    ```
    This will launch an interactive menu to select which checkpoint to restore.