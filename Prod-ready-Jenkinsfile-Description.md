Jenkinsfile Explanation — Secure & Clean Production-Ready Version

Temporary Credential Injection

Credentials (Nexus username/password, SonarQube token, Ansible credentials) are never hardcoded.

Maven commands use a temporary settings.xml with placeholders replaced by credentials at runtime.

Automatic Cleanup

After each Maven command, the temporary settings.xml is deleted immediately using a finally block.

Ensures secrets never remain on disk in the workspace.

Credentials Masking in Logs

Jenkins automatically masks any injected credentials in console logs.

Even if a build fails, passwords or tokens are never printed.

Reusable Helper Functions

runMaven() and deployAnsible() encapsulate the logic for Maven builds and Ansible deployments.

Reduces repetition and ensures consistent secret handling across all stages.

Integration With External Systems

SonarQube: Uses injected token to authenticate safely.

Nexus: Uses injected credentials for artifact upload.

Ansible: Uses injected credentials for SSH/remote deployment.

Production-Ready Practices

QA approval before production deployment.

Slack notifications for every build, showing status without revealing secrets.

Maven stages (Build, Test, Integration, Checkstyle, SonarQube) all run securely.

Clean Workspace Policy

Only necessary artifacts (.war files, reports) are retained.

Temporary files and credential-injected configs are always removed.

In short:

This Jenkinsfile builds, tests, analyzes, uploads, and deploys your Java application securely, using credentials safely, cleaning up after every build, and ensuring logs never expose secrets — all in a production-ready, maintainable structure.


                        +----------------+
                        | Jenkins Master |
                        +----------------+
                               |
                               | Credentials stored securely in Jenkins
                               | (Nexus, SonarQube, Ansible)
                               v
                     +----------------------+
                     | Pipeline Execution   |
                     | (Jenkinsfile)       |
                     +----------------------+
                               |
                               | Inject credentials temporarily
                               | into variables at runtime
                               v
           +------------------------------------------+
           | Temporary Config Files / Settings        |
           | - Maven settings.xml with placeholders   |
           | - Used ONLY during Maven commands        |
           +------------------------------------------+
                               |
                               | Maven commands use temp settings
                               | Ansible commands use injected creds
                               v
          +-------------------------------------------+
          | Build, Test, Analysis, Deployment        |
          | - Clean, package, test, sonar, nexus     |
          | - Deploy to Dev, Stage, Prod via Ansible |
          +-------------------------------------------+
                               |
                               | Temporary files deleted immediately
                               | Credentials never stored on disk
                               v
                       +----------------+
                       | Clean Workspace|
                       +----------------+
                               |
                               | Only artifacts and reports remain
                               v
                       +----------------+
                       | Slack & Logs   |
                       +----------------+
                               |
                               | Secrets masked in console logs
                               v
                       +----------------+
                       | Audit / Review |
                       +----------------+
