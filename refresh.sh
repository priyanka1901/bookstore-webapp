#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status

echo "=========================================="
echo "   Bookstore Webapp Refresh Script        "
echo "=========================================="

echo "[1/4] Stopping Tomcat server..."
./tomcat/bin/shutdown.sh >/dev/null 2>&1 || true
sleep 2 # Give Tomcat a moment to shut down

echo "[2/4] Cleaning and building project with Maven..."
mvn clean install -DskipTests

echo "[3/4] Redeploying application to Tomcat..."
# Remove old deployment (exploded directory and WAR file)
rm -rf tomcat/webapps/bookstore-webapp
rm -f tomcat/webapps/bookstore-webapp.war

# Copy the newly built WAR file
cp target/bookstore-webapp.war tomcat/webapps/

echo "[4/4] Starting Tomcat server..."
./tomcat/bin/startup.sh

echo ""
echo "=========================================="
echo "   Refresh Complete!                      "
echo "   Access at: http://localhost:8080/bookstore-webapp/"
echo "=========================================="
