#!/bin/bash
set -e

# ----------------------------------------
# 1. Update the system
# ----------------------------------------
dnf update -y

# ----------------------------------------
# 2. Install Java 17 (Amazon Corretto)
# ----------------------------------------
dnf install -y java-17-amazon-corretto java-17-amazon-corretto-devel

alternatives --install /usr/bin/java java /usr/lib/jvm/java-17-amazon-corretto/bin/java 20000
alternatives --install /usr/bin/javac javac /usr/lib/jvm/java-17-amazon-corretto/bin/javac 20000

# ----------------------------------------
# 3. Install Jenkins
# ----------------------------------------
dnf install -y wget git
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
dnf install -y jenkins

systemctl enable jenkins
systemctl start jenkins

echo "Waiting for Jenkins to start..."
sleep 30
echo "Jenkins initial admin password:"
cat /var/lib/jenkins/secrets/initialAdminPassword || echo "Password not ready yet."

echo "Access Jenkins at: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8080"

# ----------------------------------------
# 4. Install Maven 3.9.6 manually
# ----------------------------------------
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

# ----------------------------------------
# 5. Create jenkinsmaster user
# ----------------------------------------
useradd -m jenkinsmaster
echo 'jenkinsmaster:jenkinsmaster' | chpasswd
echo "jenkinsmaster ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
chown -R jenkinsmaster:jenkinsmaster /opt/maven* /opt/apache-maven-${MAVEN_VERSION} /opt/maven
echo "source /etc/profile.d/maven.sh" >> /home/jenkinsmaster/.bashrc
echo "source /etc/profile.d/maven.sh" >> /home/jenkinsmaster/.bash_profile

# ----------------------------------------
# 6. Install Ansible + AWS plugins
# ----------------------------------------
dnf install -y ansible python3-pip
pip3 install boto3
sed -i "s/^#host_key_checking = False/host_key_checking = False/" /etc/ansible/ansible.cfg
sed -i "s/^#enable_plugins = .*/enable_plugins = aws_ec2/" /etc/ansible/ansible.cfg
ansible-galaxy collection install amazon.aws

# ----------------------------------------
# 7. Create ansibleadmin user
# ----------------------------------------
useradd ansibleadmin
echo 'ansibleadmin:ansibleadmin' | chpasswd
echo "ansibleadmin ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# ----------------------------------------
# 8. Enable SSH password authentication
# ----------------------------------------
sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl restart sshd

# ----------------------------------------
# 9. Open Jenkins & SSH ports if firewalld is active
# ----------------------------------------
if systemctl is-active --quiet firewalld; then
  firewall-cmd --permanent --add-port=8080/tcp
  firewall-cmd --permanent --add-port=22/tcp
  firewall-cmd --reload
fi

echo "Setup complete!"
