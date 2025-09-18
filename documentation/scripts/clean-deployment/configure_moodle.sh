#!/bin/bash
#
# Note for AI and humans: This script configures the Moodle config.php file.
# It is executed by the deploy.sh script inside the moodle-php container.
#
set -e

CONFIG_FILE="/var/www/html/config.php"
MARKER="require_once"

# Add reverse proxy setting
sed -i "/$MARKER/i \$CFG->sslproxy = true;" "$CONFIG_FILE"

# Add SMTP settings
sed -i "/$MARKER/i \$CFG->smtpuser = '$SMTP_USER';" "$CONFIG_FILE"
sed -i "/$MARKER/i \$CFG->smtppass = '$SMTP_PASS';" "$CONFIG_FILE"
sed -i "/$MARKER/i \$CFG->smtphosts = '$SMTP_HOST:$SMTP_PORT';" "$CONFIG_FILE"
sed -i "/$MARKER/i \$CFG->smtpsecure = '$SMTP_SECURITY';" "$CONFIG_FILE"
sed -i "/$MARKER/i \$CFG->smtpauthtype = 'LOGIN';" "$CONFIG_FILE"
