#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status

# Configuration Variables
TOMCAT_VERSION="10.1.33" # Using a known stable version of Tomcat 10
TOMCAT_URL="https://archive.apache.org/dist/tomcat/tomcat-10/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz"
DB_NAME="bookstore_db"
DB_USER="root"
DB_PASS="mysql_pass" # This matches the Java code

echo "=========================================="
echo "   Bookstore Webapp Installation Script   "
echo "=========================================="

# 1. Check & Install Java 11
echo "[1/7] Checking Java 11..."
if type -p java > /dev/null; then
    JAVA_VER=$(java -version 2>&1 | head -n 1 | awk -F '"' '{print $2}')
    echo "      Found Java version: $JAVA_VER"
else
    echo "      Java not found. Installing OpenJDK 11..."
    sudo apt-get update
    sudo apt-get install -y openjdk-11-jdk
fi

# Get the Java 11 Path
JAVA_HOME_PATH=$(update-alternatives --list java | grep java-11 | head -n 1 | sed 's/\/bin\/java//')
if [ -z "$JAVA_HOME_PATH" ]; then
    echo "      ERROR: Could not locate Java 11 installation. Please install manually."
    exit 1
fi
echo "      Using JAVA_HOME: $JAVA_HOME_PATH"

# 2. Check & Install Maven
echo "[2/7] Checking Maven..."
if ! command -v mvn &> /dev/null; then
    echo "      Maven not found. Installing..."
    sudo apt-get install -y maven
else
    echo "      Maven is already installed."
fi

# 3. Check & Install MySQL
echo "[3/7] Checking MySQL..."
if ! command -v mysql &> /dev/null; then
    echo "      MySQL not found. Installing..."
    sudo apt-get install -y mysql-server
    sudo systemctl start mysql
else
    echo "      MySQL is already installed."
fi

# 4. Configure Database
echo "[4/7] Configuring Database..."
echo "      Setting MySQL root password to '$DB_PASS' (required by app)..."
# This might fail if password is already set, so we allow failure with || true
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$DB_PASS';" || echo "      (Note: Password update might have failed if already set or different auth method used. Proceeding...)"

echo "      Importing Schema from schema.sql..."
mysql -u$DB_USER -p$DB_PASS < schema.sql 2>/dev/null || sudo mysql < schema.sql

# 5. Setup Tomcat
echo "[5/7] Setting up Apache Tomcat $TOMCAT_VERSION..."
if [ ! -d "tomcat" ]; then
    mkdir -p tomcat
    echo "      Downloading Tomcat..."
    wget -q $TOMCAT_URL -O tomcat/tomcat.tar.gz
    echo "      Extracting..."
    tar -xzf tomcat/tomcat.tar.gz -C tomcat --strip-components=1
    rm tomcat/tomcat.tar.gz
    
    # Configure setenv.sh to force Java 11
    echo "      Configuring setenv.sh..."
    echo "export JAVA_HOME=\"$JAVA_HOME_PATH\"" > tomcat/bin/setenv.sh
    echo "export JRE_HOME=\"$JAVA_HOME_PATH\"" >> tomcat/bin/setenv.sh
    chmod +x tomcat/bin/*.sh
else
    echo "      Tomcat directory exists. Skipping download."
fi

# 6. Build Project
echo "[6/7] Building Project with Maven..."
mvn clean install -DskipTests

# 7. Deploy & Run
echo "[7/7] Deploying and Starting Server..."
# Remove old app if exists
rm -rf tomcat/webapps/bookstore-webapp
rm -f tomcat/webapps/bookstore-webapp.war

# Copy new war
cp target/bookstore-webapp.war tomcat/webapps/

# Stop server if running (ignore errors)
./tomcat/bin/shutdown.sh >/dev/null 2>&1 || true
sleep 2

# Start server
./tomcat/bin/startup.sh

echo ""
echo "=========================================="
echo "   SUCCESS! Application Deployed.         "
echo "=========================================="
echo "Access the application at: http://localhost:8080/bookstore-webapp/"
echo ""
echo "Admin Login: admin@bookstore.com"
echo "DB Password set to: $DB_PASS"
echo ""
