# Local metchine Work

- Unlock port 3000-10000 (our all app will go with that)
- Install Docker
- Install Kubernatives Cluster
- Install Trivy
    - Trivy installation
        - `sudo apt-get update`
        
        ```
        sudo apt-get update
        sudo apt-get install wget apt-transport-https gnupg lsb-release
        ```
        
        - `wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null`
        - `echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list`
        
        ```
        sudo apt-get update
        sudo apt-get install trivy -y
        trivy --version
        ```
        
- Install Jenkins
    
    ```
    sudo apt update
    sudo apt install fontconfig openjdk-21-jre
    java -version
    ```
    
    ```
    sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
      https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
    echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
      https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
      /etc/apt/sources.list.d/jenkins.list> /dev/null
    sudo apt update
    sudo apt install jenkins
    ```
    
    - Configure Jenkins
    - Install Plauins
        
        
        | **Eclipse Temurin Installer** | Allows Jenkins to manage multiple JDK versions for different jobs. |
        | --- | --- |
        | **SonarQube Scanner Plugin** | Connects Jenkins to SonarQube for code quality analysis. |
        | **Docker Pipeline Plugin** | Enables Docker commands and steps inside Jenkins pipelines. |
        | Docker |  |
        | JDK |  |
        | SonarQube gets |  |
        | OWASp Dependency |  |
        | **Kubernetes API** |  |
        - Configure Tools on jenkins
        - System configure
        
        ![image.png](attachment:d0a1f459-c57d-4187-9a23-f78ca5f13124:image.png)
        
        - Tools Configure
            - Add JDK installations
            name: jdk17
            install Automaticly 
            install from adption.net
            >> pic jdk version 
            11.0.19
            - SonarQube Sarver
            Name: Sonar
            install Automaticly
            
            Connet sonar with conar qube local sarver. 
            make credential.
                - Maven installations
                Name:maven3
                Install Automaticly
                
                Manage Jenkins > manage file > add a new config /- the global setting > Put name global settings.
            
            - jdk: jdk17
            global Maven settng cobfig: My global Settings > genarate pipeline.
            - Docker 
            Name: docker 
            install Automaticly from docker.com
            - OWASP
            name: dc
            Install: automaticly
        
- Install Soanr Qube in a docker container  (Code Quality Check)
`docker run -d --name sonar -p 9000:9000 sonarqube:lts-community`
    - Configure SonarQube
- Install Nexus in a docker container (Artifacts)
`docker run -d --name nexus -p 8081:8081 sonatype/nexus3`
    - Jenkins - Manage Jenkins - Jenkins files - create a new config / choose the Global maven / put a id (

# Jenkins Pipeline Setup

- New Item 
name: Ecart project

**Build The pipeline**

<aside>
💡 Create a new page and select `New Role` from the list of template options to generate the format below. Get your talking points and next steps on lock.

</aside>

# Its a Java App E-commers Store
https://github.com/abirall/Ekart.git

The Code 

```
pipeline {
    agent any

    environment {
        SONAR_HOME = tool 'sonar'
    }

    tools {
        jdk 'jdk11'
        maven 'maven'
    }

    stages {
        stage('Git clone') {
            steps {
                git branch: 'main', changelog: false, poll: false, url: 'https://github.com/abirall/Ekart.git'
            }
        }

        stage('Compile') {
            steps {
                sh 'mvn clean compile'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonar') {
                    sh "${SONAR_HOME}/bin/sonar-scanner \
                        -Dsonar.projectName=Ekart \
                        -Dsonar.projectKey=Ekart \
                        -Dsonar.java.binaries=target/classes"
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                withDockerRegistry(credentialsId: 'docker', url: '') {
                    sh "docker build -t ecart:latest ."
                    sh "docker tag ecart:latest abirall/ecart:latest"
                    sh "docker push abirall/ecart:latest"
                }
            }
        }
        stage('OWASP Dependency Check') {
            steps {
                dependencyCheck additionalArguments: '--scan ./', odcInstallation: 'dc'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }

        stage('Sonar Quality Gate') {
            steps {
                timeout(time: 2, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: false
                }
            }
        }

        stage('Trivy File System Scan') {
            steps {
                sh 'trivy fs --format table -o trivy-fs-report.html .'
            }
        }

        stage('Deploy With Docker') {
            steps {
                sh 'docker run -d abirall/ecart:latest'
            }
        }

        stage('Final Check') {
            steps {
                echo 'Success'
            }
        }
    }
}

```
