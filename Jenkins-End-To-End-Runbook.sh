Create your Jenkins-Maven-Ansible instance 
ports :
Jenkins UI port : 8080
Prometheus Node exporter: 9100
AMI : Amazon Linux 2023
Instance type : T2.medium
Pass the Jenkins-Maven-Ansible userdata

Attach ECe Full Access role or give Fine grain permissions vis IAM   ( check bottom of this page for steps)
---------------------------------------------------------------
create your sonarqube instance 
ports :
Sonarqube UI port : 9000
Prometheus Node exporter: 9100
Instance type : T2. medium
AMI : Ubuntu 24.04

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

Create a Security group : Dev-Stage-Prod-SG
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

Create a security Group : Prom-SG
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

Splunk-Indexer Instance : 
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

Go to your project code Jenkinsfile and edit the channel's name 

and push it into your github

(mine = #af-cicd-pipeline )
-------------------------------------------------------------------

Do the following steps for the Dev, stage and prod instances 

-------------------------------------------------------------------

connect to your  dev instance using ec2 instance connect

install git with : 

sudo dnf install git -y

git clone https://github.com/Oluwole-Faluwoye/realworld-cicd-pipeline-project.git

ls

cd realworld-cicd-pipeline-project

git checkout prometheus-and-grafana-install

ls  

vi install-node-exporter.sh

update the content of the install-node-exporter file with the content of  "install-Node-Exporter" in this directory

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

Select  "Status"

Select "Targets"
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

it will prompt you for the username and password

username : adminadmin
password : adminadmin

./splunk add forward-server SPLUNK_SERVER_PUBLIC_IP:9997   (update this with your splunk index public address. This tells Splunk forwarder in all the dev, stage and prod public IP address where to ship the logs to)

youll be prompted to gve your Spunk username and passoword

./splunk restart

-----------------------------------------------------------------------------------
Ensure to run all the following above commands on all  dev, stage and prod instances
------------------------------------------------------------------------------------

./splunk add monitor /var/log/tomcat/    (All system and app logs are stored in this log lcation)



you shuld have an output " Added monitor of '/var/log/tomcat/'. "

---------------------------------------------------------
Now go to your Splunk Indexer Terminal 
---------------------------------------------------------

Run these commands on your terminal  (ensure you are logged in as root )

sudo su

cd /opt/splunk/bin

./splunk enable listen 9997

You'll be prompted to input the username and password:

username : adminadmin
password : adminadmin

Now restart splunk with this command :

./splunk restart

once it restarts go to the the Splunk web UI

on the top left corner click on splunk enterprise 

click on search and reporting 

skip the tour 

click on data summary

You will see the Ip and Host names of your instances (You can use the IP to check which is the dev, stage and prod)

click on any and you will see the logs

If there are any errors from users (customers), you will see it in the logs and you can use it to have more insights into the errors
----------------------------------------------------------------------------------

copy your Jenkins public IP :8080

Then open your Jenkins instance in terminal 

run the following command to get Jenkins admin password

sudo cat /var/lib/jenkins/secrets/initialAdminPassword

copy the password and paste on Jenkins web UI

once you gain access 

click on install suggested plugins 

create your Admin user

username : admin
password : admin 

Save and Finish and you an start using Jenkins

Now we have to create a pipeline Job on the Jenkins UI

Install some plugins 

click on manage Jenkins 

click on plugins 


Now install the following Plugins 

SonarQube Scanner
Maven Integration
Pipeline Maven Integration
Maven Release Plug-In
Slack Notification
Nexus Artifact Uploader
Pipeline: Stage View
Blue Ocean
Build Timestamp
Active Choices
Ansicolor

click install 

when everything is installed,

check the box beside " Restart Jenkins when installation is complete and no jobs are running"

Once the installation is done, you would be logged out

log back into Jenkins 

username : admin 
password : admin

click on manage Jenkins 

click on Tools ( This gives you the option of adding the tools you are using in your Jenkins build)

Now we want to set Java JDK

scroll down to the  JDK installations section 

select ADD JDK

provide the name "localJdk"  

This will be the name you specified in your Jenkinsfile in the tools section 


-------------------------------------------------------------------------------------------------------------------------------
To use Java 17 follow this path
---------------------------------------------------------------------------------------

In the JAVA_HOME section you will need to provide the java home in your Jenkins Instance. This is the directory where Java was saved in your Jenkins Instance

run the command on youe Jenkins instance Terminal 

readlink -f $(which java)

You will see the output  ( /usr/lib/jvm/java-17-amazon-corretto.x86_64/bin/java )  Remove the " /bin/java " athe end and paste the rest  in your JAVA_HOME 

Paste this in the JAVA_HOME section    :     /usr/lib/jvm/java-17-amazon-corretto.x86_64


------------------------------------------------------------------------------

under SonarQube Scanner installations

Add "SONARQUBE Scanner"

select install automatically

Name : SonarQube


Under Maven Installations

install automatically

Name : localMaven

Click Save

--------------------------------------------------------------------------


-------------------------------------------------------------------------------------------

Now we need to create credentials for the different tools we want to integrate into our pipeline

Click on manage Jenkins 

click on credentials 

click on system

click on  Global credentials (unrestricted)


click Add credentials
----------------------------------------------------------------------------

copy your Sonarqube public Ip:9000 on your web browser

login 

username : admin
password : admin 

create a project 

Project name : "Java-WebApp-Project'

create a token 

Token name : Java-WebApp-Project-token

copy the token generated (only the token)

Select the build language you are using 

Mine is "Java"

select the build tool you're using 

Mine is "Maven"

This will generate a snippet for you

copy the token that was generated earlier 

----------------------------------------------------------------

Go back to the Jenkins web UI

At the kind section under credential creation 

select " secret text "

Paste the token you copied earlier under the "secret"

Under ID paste "Sonarqube-Token"

Under description paste "Sonarqube-Token"

Create credential
---------------------------------------------------------------------------

Now we need to create Slack token credential  

click Add credentials

At the kind section under credential creation 

select " secret text "

Paste the token you copied earlier during your slack integration under the "secret"

Under ID paste "Slack-Token"

Under description paste "Slack-Token"

Create credential
-------------------------------------------------------------------------

Copy your Nexus Public IP:8081

login to your Nexus instance terminal

username : admin

get your admin password with this 

sudo cat sudo cat /opt/sonatype-work/nexus3/admin.password

copy the password generated and paste it in nexus

username : admin
password : admin

Disbale anonymous access

-----------------------------------------------------------------------------

Now we need to create Nexus credential  

click Add credentials

At the kind section under credential creation 

select " username and password "

username : admin

password : admin

Paste the token you copied earlier during your slack integration under the "secret"

Under ID paste "Nexus-Credential"

Under description paste "Nexus-Credential"

Create credential

----------------------------------------------------------------------------------

Now we need to create  Ansible credential  

click Add credentials

At the kind section under credential creation 

select " username and password "

username : ansibleadmin

password : ansibleadmin

Under ID paste "Ansible-Credential"

Under description paste "Ansible-Credential"

Create credential


---------------------------------------------------------------------------------------------------------------
Go to Manage Jenkins

Select system 

Scroll down to the Slack Section 

Workspace : Paste your slack workspace name here   ( Mine is realworldcicdpipeline )

Credential : select your "Slack-Token"

Under Default channel / member id  : PASTE YOUR CHANNEL NAME HERE WITH A POUND SIGN "#" 

mine : #af-cicd-pipeline-2

Test connection 

and save
-------------------------------------------------------------------------------------------------------------------------------

Go to Manage Jenkins 

click system 

scroll down to the " Sonarqube Servers" section 

Select Environemnt variables

select Add Sonarqube

Name : SonarQube

Server URL : http://YOUR_SONARQUBE_PRIVATE_IP:9000       (update the link with your sonarqube private IP)

Under "Server authentication token"  select the " Sonarqube-Token"


----------------------------------------------------------------------------------------------------------------
(Do This is if you're using  the generic Jenkinsfile)
----------------------------------------------------------------------------------------------------------------

Go to your Sonarqube UI

copy your project name 

update the Sonarqube section of your Jenkins file with the name of your project

update the Host url section with your "Sonarqube_Private_IP"


    stage('SonarQube Inspection') {
        steps {
            withSonarQubeEnv('SonarQube') { 
                withCredentials([string(credentialsId: 'Sonarqube-Token', variable: 'SONAR_TOKEN')]) {
                sh """
                mvn sonar:sonar \
                -Dsonar.projectKey=Java-WebApp-Project \
                -Dsonar.host.url=http://Sonarqube_Private_IP:9000 \
                -Dsonar.login=$SONAR_TOKEN
                """
                }
            }
        }

--------------------------------------------------------------------------------------

Now we need to create a quality gate for Sonarqube on sonarQube UI

On the Sonarqube web UI, click on "Quality gates" 

Name : JavaWebApp-QualityGate   

Then create

Click on  "Add Condition"

condition can either be aplied to overall code or New code 

Select Oveall code

Quality Gate fails when

Select "Code Smells"

Operator VALUE : This is the maximum number of false positives it should allow before it fails the project. 

In the value inpt the number "10" or however number you and your team decide to allow based on the nature of your application.

Select Add condition

Now we need to attach the "Quality Gate" we just created to our project, which is a set of rules that allows for our source code to pass the test or not

Click on the "JavaWebApp-Project"

Click project settings 

Click on Quality Gate 

Now associate the Project with the Quality Gate you created.    "The default will be SonarWay" change it to the Quality Gate you created .

Sonarqube will need to communicate with Jenkins if the test failed or passed for Jenkins to either continue the pipeline or Pass it .

we need to create a "Webhook in Sonarqube"

Select Administration 

Select the Configuration dropdown 

Click "Webhook" and create a "Webhook"

Name: jenkinswebhook

Url: http://Jenkins_Server_Private_IP:8080/sonarqube-webhook

update the above url with your Jenkins private Ip address  (Private Ip because if you stop the instance, it will still maintain thesame private Ip when you start it)

Click create 
----------------------------------------------------------------------------------------------------------

Now we need to create a Jenkins Job

Go to Jenkins 

Click on New Item 

Name :Jenkins-Complete-CICD-Pipeline

select Pipeline

create 

----------------------------------------------------------------------------------------------------------------
(Do This is if you're using  the generic Jenkinsfile)
----------------------------------------------------------------------------------------------------------------

click on Github Project 

Paste the url of your github repo where your project is

Mine : https://github.com/Oluwole-Faluwoye/realworld-cicd-pipeline-project.git
-----------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------------------
Do this for all Jenkinsfile
------------------------------------------------------------------------------------------------------------------------
TAKE NOTE : 

Building a specific branch (e.g., main) without hardcoding in Jenkinsfile

You do not need to modify the Jenkinsfile to hardcode the branch. You have two options:

Option A: Set a Jenkins job parameter (Recommended for a regular pipeline)

In your Jenkins job:

Go to Configure → This project is parameterized → Add Parameter → String Parameter.

Name it BRANCH_NAME.

Set the default value as main.

When you click Build Now, Jenkins will use the branch specified in this parameter.

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
This alternative option Enforces Jenkins to build from the environment variable you set here all the time and you might want to build from another environment. Not suitable if youre using same Jenkins to build different branches.
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Option B: Set a Jenkins environment variable (alternative)

In your Jenkins job configuration:

Go to Build Environment → Inject environment variables.

Define BRANCH_NAME=main.

Jenkinsfile will pick it up automatically because it uses params.BRANCH_NAME ?: env.BRANCH_NAME.

✅ Result: You don’t need to touch the Jenkinsfile. The branch is dynamically picked from either parameter or environment variable.
---------------------------------------------------------------------------------------------------------------------------


 Set up a GitHub Webhook

To automatically trigger builds when you push code:

Go to your GitHub repository → Settings → Webhooks → Add webhook.

Payload URL:

http://<your-jenkins-server>:8080/github-webhook/

Jenkins Public IP since they are not in the same network


Content type: application/json

---------------------------------------------------------------------------------------------
Secret: Optional, but recommended for security.

Generate a secret string and configure the GitHub Plugin in Jenkins to match it.

Which events would you like to trigger this webhook?

Choose Just the push event (or push + pull request if needed).

Click Add webhook.
-------------------------------------------------------------------------------------------
3️⃣ Pipeline Definition in Jenkins Job

In your Jenkins job:

Pipeline section → Definition:

Choose Pipeline script from SCM (if you want Jenkins to load the Jenkinsfile from GitHub automatically), OR

Choose Pipeline script if you copy the Jenkinsfile content directly.

If using SCM:

SCM: Git

Repository URL: leave it blank if you’re using GIT_REPO credential in Jenkinsfile, OR put your repo URL.

Credentials: select your Git credential (optional if public repo)

Branches to build: leave blank (dynamic branch detection)

Script Path: Jenkinsfile (default)

If using Pipeline script (manual copy):

Paste the Jenkinsfile content you already have.

You can still set BRANCH_NAME via parameter or environment variable.


-----------------------------------------------------------------------------------------
This is for Generic Jenkinsfile
------------------------------------------------------------------
Under Pipeline 

Definition 

Select Pipeline script from SCM

Under SCM select "Git"

Paste your Github repo url link here 

since the repo is public we do not need any credentials 

Branches to build 

update with : */main

Script path : Jenkinsfile 

click on SAVE

---------------------------------------------------------------------------------------------

1️⃣ Manual Branch (Set BRANCH_NAME as an environment variable or parameter)

In the pipeline job configuration, go to This build is parameterized → add String Parameter:

Name: BRANCH_NAME

Default Value: main (or leave blank if you want)

Description: Branch to build


------------------------------------------------------------------------------------------------

2️⃣ Automatic Branch (Build triggered by SCM webhook or multibranch)

Configure GitHub webhook or Bitbucket webhook to notify Jenkins on push.

Use a Multibranch Pipeline job:

Jenkins will automatically detect branches in the repository.

You do not need to set BRANCH_NAME.



The pipeline automatically runs for the branch that was pushed.

You can then use conditional stages to deploy only on dev, stage, or main branches.

-----------------------------------------------------------------------------------

Configure Your Pipeline Job

Go to your pipeline job → Configure.

Scroll down to This project is parameterized → check the box.

Click Add Parameter → Active Choices Parameter.

Set Active Choices Parameter

Name: BRANCH_NAME

Description: Select branch to build (manual build only)

Choice Type: Single Select

Groovy Script: Paste the script (Active-Choice-Parameter).

Default Value: leave empty or set main.

Use Groovy Sandbox: Checked.

Branches to build:    */main                  


 ( */main → This tells Jenkins where to get the Jenkinsfile.   
----------------------------------------------------------------------------------------------------------------------------

Optional: Git Credentials

Add a boolean parameter for Git credentials:

Click Add Parameter → Boolean Parameter.

Name: USE_GIT_CREDENTIAL

Default: false

Description: Enable if using private Git repo

Save Job Configuration

Click Save at the bottom.



------------------------------------------------------------------------------------------------------------------------

Now build your Job 

It would fail at Nexus Artifact uplod because we havent created our repositories.
----------------------------------------------------
Make sure Git is installed on the Jenkins master
---------------------------------------------------

Now we need to configure the our repository the artifact will be deployed in

Go your Nexus UI

Click on repositories

click on create repositories 

select ' Maven 2 Hosted '

Name : maven-project-releases

version policy : release 

create repository 

---------------------------------------------------------

click on create repositories again

select ' Maven 2 Hosted '

Name : maven-project-snapshots

version policy : snapshot 

create repository 

-----------------------------------------------------------------------------------------------------------------------

if you want all the dependencies that your build needs to be stored inside your Nexus repo, you'll need to create a proxy repository.

--------------------------------------------------------------------------------------------------------------

Go your pom.xml file and update it with your Nexus_Private_IP and the names of the repositories you just created appropriately

 ( i.e the release and the snap shot repositories)

 Also ensure to update the Jenkinsfile with your Nexus_private_IP and the  names of the rpositories you just created.

------------------------------------------------------------------------------------------------------------------------------------

Now push your changes to github, your webhook should call your jenkins and start the build.


check Nexus, the artifact would have been deployed in your Nexus

check the right repo either Snapshot or Release repo

--------------------------------------------------------------------------------------------------------------------

update your aws_ec2.yaml file with the regions youre deploying to, and it would be deployed to your instances in that region using the tags you provided.

---------------------------------------------------------------------------------------------------------------------

For Jenkins to Deply into your instances, There are two approaches. 

USE IAM ROLE IF JENKINS INSTANCE AND ENVIRONRMNT INSTANCES ARE ON AWS 
----------------------------------------------------------------------------------------------------------------------

The IAM role for Jenkins must allow EC2 discovery and tagging (not S3, not EKS, etc. unless you need them).

✅ Minimum IAM Policy for Jenkins Instance Role  or EC2 full access role for a faster approach but better to give fine grain access for better security

Attach an IAM role with the following managed policies or custom inline policy:

Option 1: AWS Managed Policies

AmazonEC2ReadOnlyAccess → to allow Jenkins/Ansible dynamic inventory to list EC2 instances across regions.

AmazonSSMManagedInstanceCore (optional) if you ever want Jenkins/Ansible to connect using SSM Session Manager instead of SSH.


-----------------------------------------------------------------------------------------------------------------------------------------
Option 2: Custom Inline Policy (preferred & tighter security)

If you want least privilege, attach a role with this custom inline policy:

{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances",
        "ec2:DescribeTags",
        "ec2:DescribeRegions"
      ],
      "Resource": "*"
    }
  ]
}


This is enough for the Ansible AWS dynamic inventory plugin (aws_ec2.yaml) to work across multiple regions.
1️⃣ Create the IAM Policy (without S3)

Go to AWS Console → IAM → Policies → Create Policy → JSON tab, then paste:


--------------------------------------------------------------------------

{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances",
        "ec2:DescribeTags"
      ],
      "Resource": "*"
    }
  ]
}

----------------------------------------------------------------------------

(You can expand this if Ansible needs more EC2 actions.)


B)

Create an IAM Role:

Go to AWS Console → IAM → Roles → Create role.

Select AWS Service → EC2.

Attach the policy:


Attach Role to Jenkins EC2 Instance:

Go to EC2 → Select your Jenkins instance → Security → Modify IAM Role.

Attach the role you just created.

Use dynamic inventory without credentials:
-------------------------------------------------------------------------
Your aws_ec2.yaml already works:
------------------------------------------------------------------------------------


plugin: aws_ec2
regions:
  - us-east-1
filters:
  "tag:Environment": ["dev", "stage", "prod"]
  instance-state-name: running
keyed_groups:
  - key: tags.Environment
    prefix: tag_Environment_

-------------------------------------------------------------------------


No aws_access_key or aws_secret_key is needed.

✅ Result: Ansible automatically uses the IAM role and populates your inventory.

-----------------------------------------------------------------------------------------

You will need to manually approve to deploy to prod to ensure no bug or vulnerability is being pushed automatically to your prod. 

you would check the your dev and stage which would have been deployed to automatically to ensure the app is working perfectly

Then you can now approve to deploy to prod.

----------------------------------------------------------------------------------------------------------
PROBLEM

Our boto3 (1.40.22) and botocore (1.40.22) are too oldfrom our Jenkins-Maven-Ansible Installation script which is cusing Ansible not to see our credentials

Support for IMDSv2 (the token-based metadata service) only landed in botocore 1.13.0+ (2019) but many improvements/fixes were added in later releases.

You’re running 1.40.22, which is way behind (the latest is around boto3 1.35.x and botocore 1.35.x as of mid-2025).

That’s why boto3 can’t fetch temporary credentials from your IAM role → Ansible fails with “Unable to locate credentials”.
-----------------------------------------------------------------------------------------------------------------------------------------------

SOLUTION
-------------------------------------------------------------------
Open your Jenkins instance in terminal (i.e SSH into it)

Then

Install boto3/botocore system-wide :

run command   :  sudo pip3 install --upgrade boto3 botocore


This ensures /usr/bin/python3 (system Python) uses the upgraded boto3/botocore.

After this, test:

python3 -c "import boto3; sts=boto3.client('sts'); print(sts.get_caller_identity())"


-------------------------------------------------------------------------------------------------------------------------------------------
we were facing SSH  issues. Host checking problems
-------------------------------------------------------------------------------------------------------------------------------------------

How to solve 
----------------------------------------------------------------------------------------------------

Option 1 — Use SSH keys (recommended)

Generate a keypair (if you don’t have one):

ssh-keygen -t rsa -b 4096 -f ~/.ssh/ansibleadmin_key


Copy the public key to all EC2 hosts:

ssh-copy-id -i ~/.ssh/ansibleadmin_key.pub ansibleadmin@<ec2-ip>


Update your playbook or inventory to use the key instead of a password:

ansible_user: ansibleadmin
ansible_ssh_private_key_file: /home/jenkins/.ssh/ansibleadmin_key


Remove ansible_password from extra-vars.

✅ This is secure and avoids host key checking problems.

-----------------------------------------------------------------------------------------------------

Create a file ansible.cfg in your project root where you have deploy.yaml 
----------------------------------------------------------------------------------------------------------

Option 2 — Temporarily disable host key checking (less secure)

Add this to your ansible.cfg :

[defaults]
host_key_checking = False




