#!/bin/bash
# Update system
apt-get update -y
apt-get upgrade -y

# Install dependencies
apt-get install -y wget unzip curl gnupg software-properties-common apt-transport-https ca-certificates lsb-release

# Install Java 17 (required for SonarQube 9.x/10.x)
apt-get install -y openjdk-17-jdk

# Create a dedicated user
adduser --system --no-create-home --group --disabled-login sonarqube

# Install PostgreSQL
apt-get install -y postgresql postgresql-contrib
systemctl enable postgresql
systemctl start postgresql

# Create SonarQube database & user
sudo -u postgres psql -c "CREATE DATABASE sonarqube;"
sudo -u postgres psql -c "CREATE USER sonar WITH ENCRYPTED PASSWORD 'sonar';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE sonarqube TO sonar;"

# Download and setup SonarQube (Community Edition 10.5 as example)
cd /opt
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-10.5.0.90531.zip
unzip sonarqube-10.5.0.90531.zip
mv sonarqube-10.5.0.90531 sonarqube
chown -R sonarqube:sonarqube /opt/sonarqube

# Configure SonarQube DB settings
cat <<EOF >> /opt/sonarqube/conf/sonar.properties
sonar.jdbc.username=sonar
sonar.jdbc.password=sonar
sonar.jdbc.url=jdbc:postgresql://localhost/sonarqube
EOF

# Set system limits for SonarQube
echo "sonarqube   -   nofile   65536" >> /etc/security/limits.conf
echo "sonarqube   -   nproc    4096" >> /etc/security/limits.conf

# Create systemd service
cat <<EOF > /etc/systemd/system/sonarqube.service
[Unit]
Description=SonarQube service
After=syslog.target network.target

[Service]
Type=forking
ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop
User=sonarqube
Group=sonarqube
Restart=always
LimitNOFILE=65536
LimitNPROC=4096

[Install]
WantedBy=multi-user.target
EOF

# Enable & start SonarQube
systemctl daemon-reload
systemctl enable sonarqube
systemctl start sonarqube
