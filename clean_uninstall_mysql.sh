#!/bin/bash

echo "=================================================="
echo "   Deep Clean Uninstall of MySQL (macOS/Homebrew) "
echo "=================================================="
echo "WARNING: This will delete ALL MySQL databases and data permanently."
echo "Use this only if you want a completely fresh start."
echo ""
read -p "Are you sure you want to continue? (y/N): " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "Aborted."
    exit 0
fi

echo ""
echo "[1/6] Stopping MySQL service..."
brew services stop mysql || true
sudo pkill mysqld || true

echo "[2/6] Uninstalling MySQL via Homebrew..."
brew uninstall --force mysql || true
brew cleanup

echo "[3/6] Removing Data Directories..."
# Apple Silicon path
if [ -d "/opt/homebrew/var/mysql" ]; then
    echo "      Removing /opt/homebrew/var/mysql..."
    sudo rm -rf /opt/homebrew/var/mysql
fi
# Intel path
if [ -d "/usr/local/var/mysql" ]; then
    echo "      Removing /usr/local/var/mysql..."
    sudo rm -rf /usr/local/var/mysql
fi

echo "[4/6] Removing Configuration Files..."
sudo rm -f /opt/homebrew/etc/my.cnf
sudo rm -f /usr/local/etc/my.cnf
sudo rm -f /etc/my.cnf
rm -f ~/.my.cnf

echo "[5/6] Removing LaunchAgents and Plists..."
rm -f ~/Library/LaunchAgents/homebrew.mxcl.mysql.plist
sudo rm -f /Library/LaunchDaemons/homebrew.mxcl.mysql.plist

echo "[6/6] Cleaning up residual files..."
sudo rm -rf /usr/local/mysql*
sudo rm -rf /Library/PreferencePanes/My*
sudo rm -rf /Library/Receipts/mysql*
sudo rm -rf /Library/Receipts/MySQL*
sudo rm -rf /private/var/db/receipts/*mysql*

echo ""
echo "=================================================="
echo "   MySQL has been completely removed."
echo "   You can now run ./install.sh for a fresh install."
echo "=================================================="
