#!/bin/bash
set -ex # Exit on error, print commands

# System updates
yum update -y

# --- THIS IS THE FINAL CORRECTED SECTION ---
# Enable the PHP 8.0 repository from amazon-linux-extras
amazon-linux-extras enable php8.0

# Clean yum cache to make sure it sees the new repository
yum clean metadata

# Install Apache, wget, and the specific PHP packages needed for web serving
yum install -y httpd wget php php-mysqlnd
# --- END OF FINAL CORRECTION ---

# Start and enable Apache web server
systemctl start httpd
systemctl enable httpd

# Download and configure WordPress
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
cp -r wordpress/* /var/www/html/
chown -R apache:apache /var/www/html/
chmod -R 755 /var/www/html/

# Dynamically create the wp-config.php file
cat > /var/www/html/wp-config.php <<EOF
<?php
define( 'DB_NAME', '${db_name}' );
define( 'DB_USER', '${db_username}' );
define( 'DB_PASSWORD', '${db_password}' );
define( 'DB_HOST', '${db_endpoint}' );
define( 'DB_CHARSET', 'utf8' );
define( 'DB_COLLATE', '' );
\$table_prefix = 'wp_';
define( 'WP_DEBUG', false );
if ( ! defined( 'ABSPATH' ) ) {
    define( 'ABSPATH', __DIR__ . '/' );
}
require_once ABSPATH . 'wp-settings.php';
EOF