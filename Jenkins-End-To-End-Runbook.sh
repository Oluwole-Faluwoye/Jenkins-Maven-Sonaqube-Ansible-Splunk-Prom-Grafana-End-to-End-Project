Create your Jenkins-Maven-Ansible instance 
ports :
Jenkins UI port : 8080
Prometheus Node exporter: 9100
AMI : Amazon Linux 2023
Instance type : T2.medium
Pass the Jenkins-Maven-Ansible userdata
---------------------------------------------------------------
create your sonarqube instance 
ports :
Sonarqube UI port : 9000
Prometheus Node exporter: 9100
Instance type : T2. medium

Pass the Sonarqube userdata
--------------------------------------------------------------------

create your Nexus instance 
ports :
Nexus UI port : 8081
Prometheus Node exporter: 9100
Instance Type: T2.large

Pass the Nexus userdata
--------------------------------------------------------------------------
Dev Instance : 
ports :
UI port : 8080
Prometheus Node exporter: 9100
Splunk forwarder : 9997

AMI : Amazon Linux 2023
Instance Type : T2.micro
Add additional tag: 
Key : Environment
value : dev
userdata : Paste the Tomcat-AML2023-Deployment userdata (Depending on the AMI youre using)

------------------------------------------------------------------
Stage Instance : 
ports :
UI port : 8080
Prometheus Node exporter: 9100
Splunk forwarder : 9997

AMI : Amazon Linux 2023
Instance Type : T2.micro
Add additional tag: 
Key : Environment
value : stage
userdata : Paste the Tomcat-AML2023-Deployment userdata (Depending on the AMI youre using)

--------------------------------------------------------------------
Prod Instance : 
ports :
UI port : 8080
Prometheus Node exporter: 9100
Splunk forwarder : 9997

AMI : Amazon Linux 2023
Instance Type : T2.micro
Add additional tag: 
Key : Environment
value : prod
userdata : Paste the Tomcat-AML2023-Deployment userdata (Depending on the AMI youre using)

--------------------------------------------------------------------

Prometheus : 
ports :
Prom UI port : 9090
AMI : ubuntu 24.04
Instance type: T2.micro

IAM role : Ec2 full access

No userdata to be installed with a script inside the instance later

------------------------------------------------------------

Grafana
Ports: 
Grafana UI : 3000   0pen to 0.0.0.0 (This way you can view it on web)
(In prod you will open  port 3000 to the Prometheus_Private_IP)

AMI: ubuntu 24.04
Instance Type: T2. micro
--------------------------------------------------------------

Splunk Instance : 
AMI : Amazon Linux 2
ports :
Splunk Indexer port : 8000
Prometheus Node exporter: 9100
Splunk forwarder : 9997
Instance Type : T2.Large
--------------------------------------------------------------

Go to slack and create a new channel

After creating the channel, click on integrations

Click Add an app

select Jenkins

click on configurations

click Add to slack 

search for your Alert channel and select it

select Jenkins CI integrations

Go to the "STEP 3" of the page that will populate and copy your 

Team Subdomain and  Integration Token Credential ID:

and save the settings

--------------------------------------------------------------

Go to your Jenkinsfile and edit the channel's name 

and push it into your github
-------------------------------------------------------------------

Do these steps for the stage and prod instances as well

-------------------------------------------------------------------

connect to your  dev instance using ec2 instance connect

install git with : sudo dnf install git -y

git clone https://github.com/Oluwole-Faluwoye/realworld-cicd-pipeline-project.git

ls

cd realworld-cicd-pipeline-project

git checkout prometheus-and-grafana-install

ls  

vi install-node-exporter.sh

update the content of the install-node-exporter file with the content os  "install-Node-Exporter" in this directory

Now execute the file you just updated with the command :

bash  install-node-exporter.sh

-------------------------------------------------------------------

Log into your Prometheus server

git clone https://github.com/Oluwole-Faluwoye/realworld-cicd-pipeline-project.git

cd realworld-cicd-pipeline-project

git switch prometheus-and-grafana-install

ls

cd service-discovery

vi prometheus.yml  ( Edit the region section in this file to the region you have your instances as prometheus will scrape the metrics of all ypur instances in that region)

bash install-prometheus.sh  (This installs prometheus)

-----------------------------------------------------------------------------------

Copy your prometheus instance Public_IP:9090

Check the number of instances (nodes) that are up ( NOTE: ensure you have EC2 full access IAM rold for your prom server)
-----------------------------------------------------------------------------------

log into your Grafana instance

git clone https://github.com/Oluwole-Faluwoye/realworld-cicd-pipeline-project.git

cd realworld-cicd-pipeline-project

git switch prometheus-and-grafana-install

ls

bash install-grafana.sh

Now copy your grafana instance Public_IP:3000

Defualt username : admin
Password :admin

New username admin 
New password admin
---------------------------------------------------------------------

On the grafana UI

click on the settings icon 

select Data source

select 'add data source'

select prometheus

http://Prometheus_PUBLIC_IP:9090

Scroll down and select "save and test"

Ensure you have "Data source is working"

click on the + SIGN 

CLICK ON IMPORT

you will need a JSON file setup  for the grafana dashboard

Download from this link : https://grafana.com/api/dashboards/1860/revisions/25/download

select the import JSON and select the file you just downloaded

scroll down and select Prometheus 

Select import at the bottom 


"A dashboard will pop up showing metrics of the instances"
--------------------------------------------------------------------------------------

Now log into your Splunk instance 

wget -O splunk-9.1.1-64e843ea36b1.x86_64.rpm "https://download.splunk.com/products/splunk/releases/9.1.1/linux/splunk-9.1.1-64e843ea36b1.x86_64.rpm"

sudo yum install ./splunk-9.1.1-64e843ea36b1.x86_64.rpm -y

sudo bash

cd /opt/splunk/bin

./splunk start --accept-license --answer-yes

You will be promted to input the administrator username 

username :adminadmin
password:adminadmin

copy your splunk PUBLIC:IP:8000

username : adminadmin
password : adminadmin

When you login in, by the Administrator you'dhave a (Red) ! which indicated the system resources not enough

select settings 

select "server settings"

select general settings

at the section where you have : Pause indexing if free disk space (in MB) falls below *

change it from "5000" to "50"

run this command to restart splunk and effect the change

./splunk restart

This will kick you ut of the Splunk web UI 

log in back again 

username : adminadmin
password: adminadmin
---------------------------------------------------------------------

Open your dev,stage and prod instances in terminal 

change directory to your home directory of all the three instances if you havent just logged in : cd ..

wget -O splunk-9.1.1-64e843ea36b1.x86_64.rpm "https://download.splunk.com/products/splunk/releases/9.1.1/linux/splunk-9.1.1-64e843ea36b1.x86_64.rpm"

sudo yum install ./splunk-9.1.1-64e843ea36b1.x86_64.rpm -y

wget -O splunkforwarder-9.1.1-64e843ea36b1.x86_64.rpm "https://download.splunk.com/products/universalforwarder/releases/9.1.1/linux/splunkforwarder-9.1.1-64e843ea36b1.x86_64.rpm"

sudo yum install ./splunkforwarder-9.1.1-64e843ea36b1.x86_64.rpm -y

sudo bash

cd /opt/splunkforwarder/bin

./splunk start --accept-license --answer-yes

./splunk add forward-server SPLUNK_SERVER_PUBLIC_IP:9997   (update this with your splunk index public address. This tells Splunk forwarder in all the dev, stage and prod public IP address where to ship the logs to)

youll be prompted to gve your Spunk username and passoword

./splunk restart

-----------------------------------------------------------------------------------
Ensure to run all the following above commands on all  dev, stage and prod instances
------------------------------------------------------------------------------------

./splunk add monitor /var/log/tomcat/      (All system and app logs are stored in this log lcation)

it will prompt you for the username and password

username : adminadmin