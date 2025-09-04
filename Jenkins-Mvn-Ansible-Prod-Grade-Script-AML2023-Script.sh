#!/bin/bash
set -e

# -----------------------------
# 1. Update System
# -----------------------------
sudo dnf update -y

# -----------------------------
# 2. Install Java 17 (Amazon Corretto)
# -----------------------------
sudo dnf install -y java-17-amazon-corretto java-17-amazon-corretto-devel
sudo alternatives --install /usr/bin/java java /usr/lib/jvm/java-17-amazon-corretto/bin/java 20000
sudo alternatives --install /usr/bin/javac javac /usr/lib/jvm/java-17-amazon-corretto/bin/javac 20000
java -version

# -----------------------------
# 3. Install Jenkins
# -----------------------------
sudo dnf install -y wget git
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo dnf install -y jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins
sleep 30

echo "🔑 Jenkins initial admin password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword || echo "Password not ready yet."
echo "🌍 Access Jenkins at: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8080"

# -----------------------------
# 4. Install Maven 3.9.6
# -----------------------------
cd /opt
MAVEN_VERSION=3.9.6
sudo wget https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz
sudo tar -xvzf apache-maven-${MAVEN_VERSION}-bin.tar.gz
sudo ln -s apache-maven-${MAVEN_VERSION} maven

sudo tee /etc/profile.d/maven.sh > /dev/null << 'EOF'
export M2_HOME=/opt/maven
export PATH=$M2_HOME/bin:$PATH
EOF

sudo chmod +x /etc/profile.d/maven.sh
source /etc/profile.d/maven.sh

# -----------------------------
# 5. Create Jenkins master user
# -----------------------------
sudo useradd -m jenkinsmaster || true
echo 'jenkinsmaster:jenkinsmaster' | sudo chpasswd
echo "jenkinsmaster ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers
sudo chown -R jenkinsmaster:jenkinsmaster /opt/maven* /opt/apache-maven-${MAVEN_VERSION} /opt/maven
echo "source /etc/profile.d/maven.sh" | sudo tee -a /home/jenkinsmaster/.bashrc /home/jenkinsmaster/.bash_profile

# -----------------------------
# 6. Create .m2 directories
# -----------------------------
sudo mkdir -p /var/lib/jenkins/.m2
sudo chown -R jenkins:jenkins /var/lib/jenkins/.m2

sudo mkdir -p /home/jenkinsmaster/.m2
sudo chown -R jenkinsmaster:jenkinsmaster /home/jenkinsmaster/.m2

# -----------------------------
# 7. Install Ansible + AWS Plugins
# -----------------------------
sudo dnf install -y ansible python3-pip
pip3 install boto3
sudo sed -i "s/^#host_key_checking = False/host_key_checking = False/" /etc/ansible/ansible.cfg || true
sudo sed -i "s/^#enable_plugins = .*/enable_plugins = aws_ec2/" /etc/ansible/ansible.cfg || true
ansible-galaxy collection install amazon.aws

# -----------------------------
# 8. Create ansibleadmin user
# -----------------------------
sudo useradd ansibleadmin || true
echo 'ansibleadmin:ansibleadmin' | sudo chpasswd
echo "ansibleadmin ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers

# -----------------------------
# 9. Enable SSH password authentication
# -----------------------------
sudo sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo systemctl restart sshd

# -----------------------------
# 10. Open Jenkins & SSH ports if firewalld is active
# -----------------------------
if systemctl is-active --quiet firewalld; then
  sudo firewall-cmd --permanent --add-port=8080/tcp
  sudo firewall-cmd --permanent --add-port=22/tcp
  sudo firewall-cmd --reload
fi

echo "✅ Jenkins + Maven + Ansible setup complete on Amazon Linux 2023!"
