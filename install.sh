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

# Helper function to check connection
check_mysql_connection() {
    mysql -u root --password="$1" -e ";" 2>/dev/null
}

# 1. Check if 'mysql_pass' is already set and working
if check_mysql_connection "$DB_PASS"; then
    echo "      MySQL root password is already correct."
else
    # 2. Check if empty password works (default fresh install) OR sudo works (Linux specific)
    if mysql -u root -e ";" 2>/dev/null; then
        echo "      No MySQL root password set. Setting it to '$DB_PASS'"
        # Using simple IDENTIFIED BY to allow default plugin (caching_sha2_password)
        mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$DB_PASS';"
    elif [ "$OS" = "Linux" ] && sudo mysql -e ";" 2>/dev/null; then
         echo "      Using sudo to set password (Linux auth_socket)..."
         sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$DB_PASS';"
    else
        # 3. If we are here, neither 'mysql_pass' nor empty password works.
        # We need to ask the user.
        echo "      ! Could not connect to MySQL with empty password or '$DB_PASS'."
        echo "      ! It implies a different password is set for 'root'."
        echo "      ! Please enter your CURRENT MySQL root password so we can update it."
        echo -n "      Password: "
        read -s CURRENT_SQL_PASS
        echo ""
        
        # Try to update using the provided password
        if mysql -u root --password="$CURRENT_SQL_PASS" -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$DB_PASS';" 2>/dev/null; then
             echo "      Password successfully updated to '$DB_PASS'."
        else
             echo "      ERROR: Authentication failed with the provided password."
             echo "      Please reset your MySQL root password manually to '$DB_PASS' and run this script again."
             exit 1
        fi
    fi
fi

echo "      Creating Database Schema from create_schema.sql..."
mysql -u$DB_USER -p$DB_PASS < create_schema.sql

echo "      Initializing Sample Data from initialize_data.sql..."
mysql -u$DB_USER -p$DB_PASS < initialize_data.sql

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

echo "Admin Login: admin@bookstore.com"
echo "DB Password set to: $DB_PASS"
