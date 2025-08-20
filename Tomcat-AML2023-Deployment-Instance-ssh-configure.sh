#!/bin/bash
# ==========================
# Amazon Linux 2023: Java 17 + Tomcat 9.0.94 + ansibleadmin user
# ==========================

set -e

# --------------------------
# Update system and install Java 17
# --------------------------
dnf update -y
dnf install -y java-17-amazon-corretto-devel

# --------------------------
# Create ansibleadmin user
# --------------------------
id -u ansibleadmin &>/dev/null || useradd ansibleadmin
echo ansibleadmin | passwd ansibleadmin --stdin
sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
systemctl restart sshd
echo "ansibleadmin ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# --------------------------
# Download and install Tomcat 9.0.94
# --------------------------
cd /opt
curl -O -L https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.94/bin/apache-tomcat-9.0.94.tar.gz
tar xzf apache-tomcat-9.0.94.tar.gz
mv apache-tomcat-9.0.94 tomcat9
chown -R ec2-user:ec2-user /opt/tomcat9
chmod +x /opt/tomcat9/bin/*.sh

# --------------------------
# Create systemd service for Tomcat
# --------------------------
cat <<EOF > /etc/systemd/system/tomcat.service
[Unit]
Description=Apache Tomcat 9
After=network.target

[Service]
Type=forking

User=ec2-user
Group=ec2-user

Environment="JAVA_HOME=/usr/lib/jvm/java-17-amazon-corretto"
Environment="CATALINA_HOME=/opt/tomcat9"
Environment="CATALINA_BASE=/opt/tomcat9"
Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"

ExecStart=/opt/tomcat9/bin/startup.sh
ExecStop=/opt/tomcat9/bin/shutdown.sh

Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# --------------------------
# Enable and start Tomcat service
# --------------------------
systemctl daemon-reload
systemctl enable tomcat
systemctl start tomcat
