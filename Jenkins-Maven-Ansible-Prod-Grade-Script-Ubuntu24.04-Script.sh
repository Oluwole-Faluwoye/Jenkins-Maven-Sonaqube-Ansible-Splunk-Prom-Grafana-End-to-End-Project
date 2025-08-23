#!/bin/bash
set -e

# -----------------------------
# 1. Update System
# -----------------------------
apt update -y && apt upgrade -y

# -----------------------------
# 2. Install Java 17 (OpenJDK)
# -----------------------------
apt install -y openjdk-17-jdk wget git curl unzip
update-alternatives --install /usr/bin/java java /usr/lib/jvm/java-17-openjdk-amd64/bin/java 20000
update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/java-17-openjdk-amd64/bin/javac 20000

# -----------------------------
# 3. Install Jenkins
# -----------------------------
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | apt-key add -
sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
apt update -y
apt install -y jenkins

systemctl enable jenkins
systemctl start jenkins
sleep 30

echo "Jenkins initial admin password:"
cat /var/lib/jenkins/secrets/initialAdminPassword || echo "Password not ready yet."
echo "Access Jenkins at: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8080"

# -----------------------------
# 4. Install Maven 3.9.6
# -----------------------------
cd /opt
MAVEN_VERSION=3.9.6
wget https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz
tar -xvzf apache-maven-${MAVEN_VERSION}-bin.tar.gz
ln -s apache-maven-${MAVEN_VERSION} maven

tee /etc/profile.d/maven.sh > /dev/null << 'EOF'
export M2_HOME=/opt/maven
export PATH=$M2_HOME/bin:$PATH
EOF

chmod +x /etc/profile.d/maven.sh
source /etc/profile.d/maven.sh

# -----------------------------
# 5. Create Jenkins master user
# -----------------------------
useradd -m jenkinsmaster
echo 'jenkinsmaster:jenkinsmaster' | chpasswd
echo "jenkinsmaster ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
chown -R jenkinsmaster:jenkinsmaster /opt/maven* /opt/apache-maven-${MAVEN_VERSION} /opt/maven
echo "source /etc/profile.d/maven.sh" >> /home/jenkinsmaster/.bashrc
echo "source /etc/profile.d/maven.sh" >> /home/jenkinsmaster/.bash_profile

# -----------------------------
# 6. Create .m2 directories
# -----------------------------
mkdir -p /var/lib/jenkins/.m2
chown -R jenkins:jenkins /var/lib/jenkins/.m2

mkdir -p /home/jenkinsmaster/.m2
chown -R jenkinsmaster:jenkinsmaster /home/jenkinsmaster/.m2

# -----------------------------
# 7. Install Ansible + AWS Plugins
# -----------------------------
apt install -y ansible python3-pip
pip3 install boto3
sed -i "s/^#host_key_checking = False/host_key_checking = False/" /etc/ansible/ansible.cfg
sed -i "s/^#enable_plugins = .*/enable_plugins = aws_ec2/" /etc/ansible/ansible.cfg
ansible-galaxy collection install amazon.aws

# -----------------------------
# 8. Create ansibleadmin user
# -----------------------------
useradd ansibleadmin
echo 'ansibleadmin:ansibleadmin' | chpasswd
echo "ansibleadmin ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# -----------------------------
# 9. Enable SSH password authentication
# -----------------------------
sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl restart ssh

# -----------------------------
# 10. Open Jenkins & SSH ports if ufw active
# -----------------------------
if command -v ufw >/dev/null 2>&1; then
  ufw allow 8080/tcp
  ufw allow 22/tcp
  ufw reload || true
fi

echo "✅ Ubuntu 24.04 CI/CD setup complete!"
