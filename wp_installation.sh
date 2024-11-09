#!/bin/bash

# Create a directory named "wordpress"
mkdir wordpress

# Change to the "wordpress" directory
cd wordpress

# Install Apache2
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install -y apache2

# Start Apache2 service
sudo systemctl start apache2

# Enable Apache2 to start on boot
sudo systemctl enable apache2

# Display a message indicating successful installation
echo "WordPress directory created and Apache2 installed successfully!"

# Install PHP version 8
sudo apt install -y php php-{common,mysql,xml,xmlrpc,curl,gd,imagick,cli,dev,imap,mbstring,opcache,soap,zip,intl}

# To Check the version of PHP
php -v

# Install mariaDB or MySQL
sudo apt install mariadb-server mariadb-client -y

# Enable, start and check service status
sudo systemctl enable --now mariadb

# Check if the script is run with sudo
[ "$EUID" -ne 0 ] && { echo "Please run this script with sudo or as root."; exit 1; }

# Run mysql_secure_installation
sudo mysql_secure_installation 

# Display a message indicating successful execution
echo "MySQL secure installation completed successfully!"

# Ask for MySQL root password
read -s -p "Enter MySQL root password: " root_password && echo

# Ask for MySQL username
read -p "Enter MySQL username: " username

# Ask for MySQL user password
read -s -p "Enter MySQL user password for '$username': " user_password && echo

# Ask for MySQL database name
read -p "Enter MySQL database name: " database_name

# MySQL commands
mysql_commands=$(cat <<EOF
CREATE USER '$username'@'localhost' IDENTIFIED BY '$user_password';
CREATE DATABASE IF NOT EXISTS DB;
GRANT ALL PRIVILEGES ON DB.* TO '$username'@'localhost';
FLUSH PRIVILEGES;
EXIT
EOF
)

# Execute MySQL commands with sudo and root password from input
if echo "$mysql_commands" | sudo -S mysql -u root -p"$root_password"; then
  echo "MySQL commands executed successfully!"
else
  echo "Error: Failed to execute MySQL commands."
fi




# Install required packages
sudo apt-get update
sudo apt-get install -y wget unzip

# Download and unzip WordPress
wget https://wordpress.org/latest.zip
sudo unzip latest.zip

# Define directories
destination_dir="/var/www/html/wordpress"
backup_dir="/var/www/html/old_wordpress_$(date +'%Y%m%d_%H%M%S')"

# Check if the destination directory exists
if [ -d "$destination_dir" ]; then
  # Rename existing directory
  sudo mv "$destination_dir" "$backup_dir"
  echo "Existing directory moved to $backup_dir"
fi

# Move the new 'wordpress/' directory
sudo mv wordpress/ "$destination_dir"
echo "New directory moved to $destination_dir"


# Clean up downloaded zip file
sudo rm latest.zip

# Set correct ownership and permissions for web server
sudo chown www-data:www-data -R /var/www/html/wordpress/
sudo chmod -R 777 /var/www/html/wordpress/

echo "WordPress installation completed successfully."



# Create and edit the WordPress virtual host configuration file
sudo tee /etc/apache2/sites-available/wordpress.conf > /dev/null <<EOF
<VirtualHost *:80>
ServerAdmin admin@example.com

DocumentRoot /var/www/html/wordpress
ServerName example.com
ServerAlias www.example.com

<Directory /var/www/html/wordpress/>

Options FollowSymLinks
AllowOverride All
Require all granted

</Directory>

ErrorLog \${APACHE_LOG_DIR}/error.log
CustomLog \${APACHE_LOG_DIR}/access.log combined

</VirtualHost>
EOF


# Enable the WordPress virtual host
sudo a2ensite wordpress.conf

# Enable the rewrite module
sudo a2enmod rewrite

# Disable the default Apache test page
sudo a2dissite 000-default.conf

# Restart Apache
sudo systemctl restart apache2


echo "WordPress virtual host configuration completed successfully!"

