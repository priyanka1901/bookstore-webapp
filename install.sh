#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status

# Configuration Variables
TOMCAT_VERSION="10.1.33"
TOMCAT_URL="https://archive.apache.org/dist/tomcat/tomcat-10/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz"
DB_NAME="bookstore_db"
DB_USER="root"
DB_PASS="mysql_pass"

# Detect OS
OS="$(uname -s)"
echo "Detected OS: $OS"

echo "=========================================="
echo "   Bookstore Webapp Installation Script   "
echo "=========================================="

# ---------------------------------------------------------
# 1. Check & Install Java 11
# ---------------------------------------------------------
echo "[1/7] Checking Java 11..."

if [ "$OS" = "Darwin" ]; then
    # macOS Logic
    if /usr/libexec/java_home -v 11 &> /dev/null; then
        JAVA_HOME_PATH=$(/usr/libexec/java_home -v 11)
        echo "      Found Java 11 at: $JAVA_HOME_PATH"
    else
        echo "      Java 11 not found. Installing via Homebrew..."
        if ! command -v brew &> /dev/null; then
            echo "      Error: Homebrew is not installed. Please install Homebrew first."
            exit 1
        fi
        brew install openjdk@11
        # Link it so java_home can find it
        sudo ln -sfn /opt/homebrew/opt/openjdk@11/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-11.jdk || true
        JAVA_HOME_PATH=$(/usr/libexec/java_home -v 11)
    fi
elif [ "$OS" = "Linux" ]; then
    # Linux Logic
    if type -p java > /dev/null; then
        echo "      Java is installed."
    else
        echo "      Java not found. Installing OpenJDK 11..."
        sudo apt-get update
        sudo apt-get install -y openjdk-11-jdk
    fi
    # Find path
    JAVA_HOME_PATH=$(update-alternatives --list java | grep java-11 | head -n 1 | sed 's/\/bin\/java//')
else
    echo "      Unsupported OS. Please install Java 11 manually."
    exit 1
fi

if [ -z "$JAVA_HOME_PATH" ]; then
    echo "      ERROR: Could not locate Java 11 installation. Please install manually."
    exit 1
fi
echo "      Using JAVA_HOME: $JAVA_HOME_PATH"

# ---------------------------------------------------------
# 2. Check & Install Maven
# ---------------------------------------------------------
echo "[2/7] Checking Maven..."
if ! command -v mvn &> /dev/null; then
    echo "      Maven not found. Installing..."
    if [ "$OS" = "Darwin" ]; then
        brew install maven
    elif [ "$OS" = "Linux" ]; then
        sudo apt-get install -y maven
    fi
else
    echo "      Maven is already installed."
fi

# ---------------------------------------------------------
# 3. Check & Install MySQL
# ---------------------------------------------------------
echo "[3/7] Checking MySQL..."
if ! command -v mysql &> /dev/null; then
    echo "      MySQL not found. Installing..."
    if [ "$OS" = "Darwin" ]; then
        brew install mysql
        brew services start mysql
    elif [ "$OS" = "Linux" ]; then
        sudo apt-get install -y mysql-server
        sudo systemctl start mysql
    fi
    echo "      Waiting for MySQL to start..."
    sleep 5
else
    echo "      MySQL is already installed."
fi

# ---------------------------------------------------------
# 4. Configure Database
# ---------------------------------------------------------
echo "[4/7] Configuring Database..."
echo "      Setting MySQL root password to '$DB_PASS' (required by app)..."

# Attempt to set password. 
# On macOS/Homebrew, the socket file might be in /tmp or generated dynamically.
# 'mysql -e' usually works if the service is running.
if [ "$OS" = "Darwin" ]; then
    # Homebrew MySQL usually has no password by default
    mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$DB_PASS';" 2>/dev/null || echo "      (Pass update skipped or failed - checking connection...)"
else
    # Linux often requires sudo for root socket access initially
    sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$DB_PASS';" || echo "      (Note: Password update might have failed if already set. Proceeding...)"
fi

echo "      Importing Schema from schema.sql..."
# Try connecting with the new password
mysql -u$DB_USER -p$DB_PASS < schema.sql 2>/dev/null || {
    echo "      Could not connect with password. Trying without password (for Linux sudo access)..."
    sudo mysql < schema.sql
}

# ---------------------------------------------------------
# 5. Setup Tomcat
# ---------------------------------------------------------
echo "[5/7] Setting up Apache Tomcat $TOMCAT_VERSION..."
if [ ! -d "tomcat" ]; then
    mkdir -p tomcat
    echo "      Downloading Tomcat..."
    # Use curl -L to follow redirects, -o for output
    curl -L -o tomcat/tomcat.tar.gz "$TOMCAT_URL"
    
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

# ---------------------------------------------------------
# 6. Build Project
# ---------------------------------------------------------
echo "[6/7] Building Project with Maven..."
mvn clean install -DskipTests

# ---------------------------------------------------------
# 7. Deploy & Run
# ---------------------------------------------------------
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