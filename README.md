---
services: app-service, Service-Bus
platforms: java
author: selvasingh, sadigopu
---

# Migrate Java EE Apps to Azure

This guide walks you through the process of migrating 
existing Java EE workloads to Azure, aka:
 
- Java enterprise apps (message driven enterprise beans) to App Service Linux
- App's messaging subsystem to Azure Service Bus
- Leverage Web Sockets for interactive Java workloads 

## Table of Contents

   * [Migrate Java EE Apps to Azure](#migrate-java-ee-apps-to-azure)
      * [Table of Contents](#table-of-contents)
      * [What you will migrate to cloud](#what-you-will-migrate-to-cloud)
      * [What you will need](#what-you-will-need)
      * [Getting Started](#getting-started)
         * [Step ONE - Clone and Prep](#step-one---clone-and-prep)
      * [Build Sample Archive](#build-sample-archive)
      * [Build Console App - send and receive messages to Service Bus using JMS](#build-console-app---send-and-receive-messages-to-service-bus-using-jms)
         * [Create and Configure Azure Service Bus](#create-and-configure-azure-service-bus)
         * [Build and Run Console App](#build-and-run-console-app)
      * [Migrate a message driven enterprise bean to Azure](#migrate-a-message-driven-enterprise-bean-to-azure)
         * [Prepare Environment](#prepare-environment)
         * [Deploy App to App Service Linux](#deploy-app-to-app-service-linux)
         * [Configure JMS Resource Adapter ( JMS RA)](#configure-jms-resource-adapter--jms-ra)
            * [Step 1: Understand How to configure WildFly](#step-1-understand-how-to-configure-wildfly)
            * [Step 2 - Upload Startup and Binary Artifacts to App through FTP](#step-2---upload-startup-and-binary-artifacts-to-app-through-ftp)
               * [Get FTP Deployment Credentials](#get-ftp-deployment-credentials)
               * [Upload Startup and Binary Artifacts to App through FTP](#upload-startup-and-binary-artifacts-to-app-through-ftp)
            * [Step 4: Test the JBoss/WildFly Startup Script and CLI Commands to Configure JMS RA](#step-4-test-the-jbosswildfly-startup-script-and-cli-commands-to-configure-jms-ra)
               * [Test the startup.sh script](#test-the-startupsh-script)
            * [Step 5: Restart the remote WildFly app server](#step-5-restart-the-remote-wildfly-app-server)
            * [Step 6: Stream WildFly/JBoss logs to a dev machine](#step-6-stream-wildflyjboss-logs-to-a-dev-machine)
         * [Open the Message-Driven Enterprise Bean on Azure](#open-the-message-driven-enterprise-bean-on-azure)
         * [Additional Info](#additional-info)
      * [Migrate Java Enterprise App that uses WebSockets](#migrate-java-enterprise-app-that-uses-websockets)
         * [Deploy App to App Service Linux](#deploy-app-to-app-service-linux-1)
         * [Open the Migrated App on App Service Linux](#open-the-migrated-app-on-app-service-linux)
      * [Congratulations!](#congratulations)
      * [Resources](#resources)

## What you will migrate to cloud

You will migrate WildFly/JBoss sample apps to Azure. These
 apps use:

- Java SE 8
- Java EE 7
- JSR 343 Java Messaging Service 2.0 (JMS)
- JSR 356 Java API for WebSocket

Upon migration, you will power the apps using 
Azure Service Bus.

## What you will need

In order to deploy a Java Web app to cloud, you need 
an Azure subscription. If you do not already have an Azure 
subscription, you can activate your 
[MSDN subscriber benefits](https://azure.microsoft.com/pricing/member-offers/msdn-benefits-details/) 
or sign up for a 
[free Azure account]((https://azure.microsoft.com/pricing/free-trial/)).

In addition, you will need the following:

| [Azure CLI](http://docs.microsoft.com/cli/azure/overview) 
| [Java 8](https://www.azul.com/downloads/azure-only/zulu/) 
| [Maven 3](http://maven.apache.org/) 
| [Git](https://github.com/)
|

## Getting Started

You can start from scratch and complete each step, or 
you can bypass basic setup steps that you are already 
familiar with. Either way, you will end up with working code.

### Step ONE - Clone and Prep

```bash
git clone --recurse-submodules https://github.com/Azure-Samples/migrate-java-ee-app-to-azure-2
cd migrate-Java-EE-app-to-azure-2
yes | cp -rf .prep/* .
```

## Build Sample Archive

Build the sample archive using Maven. This step will take a few minutes.

```bash
cd quickstart

mvn clean install
```


```bash
[INFO] Scanning for projects...
[INFO] ------------------------------------------------------------------------
[INFO] Reactor Build Order:
[INFO] 
[INFO] Quickstart: Parent
[INFO] Quickstart: app-client
[INFO] Quickstart: app-client - ejb
[INFO] Quickstart: app-client - client-simple
[INFO] Quickstart: app-client - ear
...
...
[INFO] Installing /Users/selvasingh/migrate-java-ee-app-to-azure-2/quickstart/wsba-participant-completion-simple/target/wsba-participant-completion-simple-sources.jar to /Users/selvasingh/.m2/repository/org/wildfly/quickstarts/wsba-participant-completion-simple/14.0.1.Final/wsba-participant-completion-simple-14.0.1.Final-sources.jar
[INFO] ------------------------------------------------------------------------
[INFO] Reactor Summary:
[INFO] 
[INFO] Quickstart: Parent ................................. SUCCESS [  1.697 s]
[INFO] Quickstart: app-client ............................. SUCCESS [  0.015 s]
[INFO] Quickstart: app-client - ejb ....................... SUCCESS [  2.177 s]
[INFO] Quickstart: app-client - client-simple ............. SUCCESS [  0.646 s]
[INFO] Quickstart: app-client - ear ....................... SUCCESS [  0.723 s]
[INFO] Quickstart: batch-processing ....................... SUCCESS [  1.736 s]
[INFO] Quickstart: bean-validation ........................ SUCCESS [  0.482 s]
[INFO] Quickstart: bean-validation-custom-constraint ...... SUCCESS [  0.295 s]
[INFO] Quickstart: bmt .................................... SUCCESS [  0.291 s]
[INFO] Quickstart: cmt .................................... SUCCESS [  1.642 s]
[INFO] Quickstart: contacts-jquerymobile .................. SUCCESS [  1.351 s]
[INFO] Quickstart: deltaspike-authorization ............... SUCCESS [  0.265 s]
[INFO] Quickstart: deltaspike-beanbuilder ................. SUCCESS [  0.387 s]
[INFO] Quickstart: deltaspike-projectstage ................ SUCCESS [  0.150 s]
[INFO] Quickstart: ejb-asynchronous ....................... SUCCESS [  0.011 s]
[INFO] Quickstart: ejb-asynchronous - ejb ................. SUCCESS [  0.161 s]
[INFO] Quickstart: ejb-asynchronous - client .............. SUCCESS [  0.157 s]
[INFO] Quickstart: ejb-in-ear ............................. SUCCESS [  0.010 s]
[INFO] Quickstart: ejb-in-ear - ejb ....................... SUCCESS [  0.133 s]
[INFO] Quickstart: ejb-in-ear - web ....................... SUCCESS [  0.143 s]
[INFO] Quickstart: ejb-in-ear - ear ....................... SUCCESS [  0.216 s]
[INFO] Quickstart: ejb-in-war ............................. SUCCESS [  0.224 s]
[INFO] Quickstart: ejb-multi-server ....................... SUCCESS [  0.014 s]
[INFO] Quickstart: ejb-multi-server - app-one ............. SUCCESS [  0.012 s]
[INFO] Quickstart: ejb-multi-server - app-one - ejb ....... SUCCESS [  0.148 s]
[INFO] Quickstart: ejb-multi-server - app-one - ear ....... SUCCESS [  0.030 s]
[INFO] Quickstart: ejb-multi-server - app-two ............. SUCCESS [  0.014 s]
[INFO] Quickstart: ejb-multi-server - app-two - ejb ....... SUCCESS [  0.207 s]
[INFO] Quickstart: ejb-multi-server - app-two - ear ....... SUCCESS [  0.031 s]
[INFO] Quickstart: ejb-multi-server - app-main ............ SUCCESS [  0.015 s]
[INFO] Quickstart: ejb-multi-server - app-main - ejb ...... SUCCESS [  0.222 s]
[INFO] Quickstart: ejb-multi-server - app-main - web ...... SUCCESS [  0.252 s]
[INFO] Quickstart: ejb-multi-server - app-main - ear ...... SUCCESS [  0.078 s]
[INFO] Quickstart: ejb-multi-server - app-web ............. SUCCESS [  0.343 s]
[INFO] Quickstart: ejb-multi-server - client .............. SUCCESS [  0.277 s]
[INFO] Quickstart: ejb-security ........................... SUCCESS [  0.302 s]
[INFO] Quickstart: ejb-security-context-propagation ....... SUCCESS [  0.227 s]
[INFO] Quickstart: ejb-security-jaas ...................... SUCCESS [  0.368 s]
[INFO] Quickstart: ejb-security-programmatic-auth ......... SUCCESS [  0.155 s]
[INFO] Quickstart: ejb-throws-exception ................... SUCCESS [  0.009 s]
[INFO] Quickstart: ejb-throws-exception - ejb-api ......... SUCCESS [  0.115 s]
[INFO] Quickstart: ejb-throws-exception - ejb ............. SUCCESS [  0.108 s]
[INFO] Quickstart: ejb-throws-exception - web ............. SUCCESS [  0.145 s]
[INFO] Quickstart: ejb-throws-exception - ear ............. SUCCESS [  0.030 s]
[INFO] Quickstart: ejb-timer .............................. SUCCESS [  0.136 s]
[INFO] Quickstart: greeter ................................ SUCCESS [  0.187 s]
[INFO] Quickstart: HA Singleton Deployment ................ SUCCESS [  0.114 s]
[INFO] Quickstart: HA Singleton Service (parent) .......... SUCCESS [  0.038 s]
[INFO] Quickstart: HA Singleton Service - primary-only .... SUCCESS [  0.160 s]
[INFO] Quickstart: HA Singleton Service - with backups .... SUCCESS [  0.133 s]
[INFO] Quickstart: helloworld ............................. SUCCESS [  0.139 s]
[INFO] Quickstart: Hello World ClassFileTransformers ...... SUCCESS [  0.251 s]
[INFO] Quickstart: helloworld-html5 ....................... SUCCESS [  0.127 s]
[INFO] Quickstart: helloworld-jms ......................... SUCCESS [ 24.354 s]
[INFO] Quickstart: helloworld-mbean ....................... SUCCESS [  0.017 s]
[INFO] Quickstart: helloworld-mbean - helloworld-mbean-webapp SUCCESS [  0.271 s]
[INFO] Quickstart: helloworld-mbean - helloworld-mbean-service SUCCESS [  1.730 s]
[INFO] Quickstart: helloworld-mdb ......................... SUCCESS [  1.260 s]
[INFO] Quickstart: helloworld-mdb-propertysubstitution .... SUCCESS [  0.147 s]
[INFO] Quickstart: helloworld-mutual-ssl .................. SUCCESS [  0.343 s]
[INFO] Quickstart: helloworld-mutual-ssl-secured .......... SUCCESS [  0.331 s]
[INFO] Quickstart: helloworld-rf .......................... SUCCESS [  0.546 s]
[INFO] Quickstart: helloworld-rs .......................... SUCCESS [  0.106 s]
[INFO] Quickstart: helloworld-singleton ................... SUCCESS [  0.121 s]
[INFO] Quickstart: helloworld-ssl ......................... SUCCESS [  0.109 s]
[INFO] Quickstart: helloworld-ws .......................... SUCCESS [  0.827 s]
[INFO] Quickstart: hibernate4 ............................. SUCCESS [  0.481 s]
[INFO] Quickstart: hibernate .............................. SUCCESS [  0.229 s]
[INFO] Quickstart: http-custom-mechanism .................. SUCCESS [  0.012 s]
[INFO] Quickstart: http-custom-mechanism - webapp ......... SUCCESS [  0.196 s]
[INFO] Quickstart: inter-app .............................. SUCCESS [  0.009 s]
[INFO] Quickstart: inter-app - shared ..................... SUCCESS [  0.094 s]
[INFO] Quickstart: inter-app - appA ....................... SUCCESS [  0.111 s]
[INFO] Quickstart: inter-app - appB ....................... SUCCESS [  0.123 s]
[INFO] Quickstart: jaxrs-client ........................... SUCCESS [  0.286 s]
[INFO] Quickstart: jaxrs-jwt .............................. SUCCESS [  0.011 s]
[INFO] Quickstart: jaxrs-jwt - client ..................... SUCCESS [  0.135 s]
[INFO] Quickstart: jaxrs-jwt - service .................... SUCCESS [  0.513 s]
[INFO] Quickstart: jaxws-addressing ....................... SUCCESS [  0.010 s]
[INFO] Quickstart: jaxws-addressing - service ............. SUCCESS [  0.115 s]
[INFO] Quickstart: jaxws-addressing - client .............. SUCCESS [  0.693 s]
[INFO] Quickstart: jaxws-ejb .............................. SUCCESS [  0.009 s]
[INFO] Quickstart: jaxws-ejb - service .................... SUCCESS [  0.133 s]
[INFO] Quickstart: jaxws-ejb - client ..................... SUCCESS [  0.147 s]
[INFO] Quickstart: jaxws-pojo ............................. SUCCESS [  0.010 s]
[INFO] Quickstart: jaxws-pojo - service ................... SUCCESS [  0.125 s]
[INFO] Quickstart: jaxws-pojo - client .................... SUCCESS [  0.191 s]
[INFO] Quickstart: jaxws-retail ........................... SUCCESS [  0.011 s]
[INFO] Quickstart: jaxws-retail - service ................. SUCCESS [  2.587 s]
[INFO] Quickstart: jaxws-retail - client .................. SUCCESS [  0.153 s]
[INFO] Quickstart: jsonp .................................. SUCCESS [  0.136 s]
[INFO] Quickstart: kitchensink ............................ SUCCESS [  0.758 s]
[INFO] Quickstart: kitchensink-angularjs .................. SUCCESS [  0.806 s]
[INFO] Quickstart: kitchensink-ear ........................ SUCCESS [  0.009 s]
[INFO] Quickstart: kitchensink-ear - ejb .................. SUCCESS [  0.181 s]
[INFO] Quickstart: kitchensink-ear - web .................. SUCCESS [  0.166 s]
[INFO] Quickstart: kitchensink-ear - ear .................. SUCCESS [  0.032 s]
[INFO] Quickstart: kitchensink-jsp ........................ SUCCESS [  0.669 s]
[INFO] Quickstart: kitchensink-ml ......................... SUCCESS [  0.901 s]
[INFO] Quickstart: Kitchensink with Undertow.JS and AngularJS SUCCESS [  0.230 s]
[INFO] Quickstart: Kitchensink with Undertow.JS and Mustach SUCCESS [  0.031 s]
[INFO] Quickstart: logging ................................ SUCCESS [  0.092 s]
[INFO] Quickstart: logging-tools .......................... SUCCESS [  0.778 s]
[INFO] Quickstart: mail ................................... SUCCESS [  0.163 s]
[INFO] Quickstart: managed-executor-service ............... SUCCESS [  0.201 s]
[INFO] Quickstart: messaging-clustering-singleton ......... SUCCESS [  0.114 s]
[INFO] Quickstart: numberguess ............................ SUCCESS [  0.131 s]
[INFO] Quickstart: payment-cdi-event ...................... SUCCESS [  0.162 s]
[INFO] Quickstart: resteasy-jaxrs-client .................. SUCCESS [  0.094 s]
[INFO] Quickstart: security-domain-to-domain .............. SUCCESS [  0.007 s]
[INFO] Quickstart: security-domain-to-domain - ejb ........ SUCCESS [  0.088 s]
[INFO] Quickstart: security-domain-to-domain - web ........ SUCCESS [  0.122 s]
[INFO] Quickstart: security-domain-to-domain - ear ........ SUCCESS [  0.025 s]
[INFO] Quickstart: servlet-async .......................... SUCCESS [  0.133 s]
[INFO] Quickstart: servlet-filterlistener ................. SUCCESS [  0.125 s]
[INFO] Quickstart: servlet-security ....................... SUCCESS [  0.125 s]
[INFO] Quickstart: shopping-cart .......................... SUCCESS [  0.008 s]
[INFO] Quickstart: shopping-cart - server ................. SUCCESS [  0.095 s]
[INFO] Quickstart: shopping-cart - client ................. SUCCESS [  0.090 s]
[INFO] Quickstart: spring-greeter ......................... SUCCESS [  0.313 s]
[INFO] Quickstart: spring-kitchensink-basic ............... SUCCESS [  3.836 s]
[INFO] Quickstart: spring-kitchensink-springmvctest ....... SUCCESS [  4.767 s]
[INFO] Quickstart: spring-resteasy ........................ SUCCESS [  0.316 s]
[INFO] Quickstart: tasks-jsf .............................. SUCCESS [  0.826 s]
[INFO] Quickstart: tasks-rs ............................... SUCCESS [  0.194 s]
[INFO] Quickstart: temperature-converter .................. SUCCESS [  0.116 s]
[INFO] Quickstart: thread-racing .......................... SUCCESS [  0.305 s]
[INFO] Quickstart: websocket-client ....................... SUCCESS [  0.242 s]
[INFO] Quickstart: websocket-endpoint ..................... SUCCESS [  0.215 s]
[INFO] Quickstart: websocket-hello ........................ SUCCESS [  0.110 s]
[INFO] Quickstart: wicket-ear ............................. SUCCESS [  0.009 s]
[INFO] Quickstart: wicket-ear - ejb ....................... SUCCESS [  0.093 s]
[INFO] Quickstart: wicket-ear - war ....................... SUCCESS [  0.303 s]
[INFO] Quickstart: wicket-ear - ear ....................... SUCCESS [  0.149 s]
[INFO] Quickstart: wicket-war ............................. SUCCESS [  0.260 s]
[INFO] Quickstart: xml-jaxp ............................... SUCCESS [  0.175 s]
[INFO] Quickstart: jts .................................... SUCCESS [  0.008 s]
[INFO] Quickstart: jts - application-component-2 .......... SUCCESS [  0.146 s]
[INFO] Quickstart: jts - application-component-1 .......... SUCCESS [  0.114 s]
[INFO] Quickstart: ejb-remote ............................. SUCCESS [  0.011 s]
[INFO] Quickstart: ejb-remote - server-side ............... SUCCESS [  0.115 s]
[INFO] Quickstart: ejb-remote - client .................... SUCCESS [  0.109 s]
[INFO] Quickstart: jta-crash-rec .......................... SUCCESS [  0.163 s]
[INFO] Quickstart: wsat-simple ............................ SUCCESS [  0.240 s]
[INFO] Quickstart: wsba-coordinator-completion-simple ..... SUCCESS [  0.232 s]
[INFO] Quickstart: wsba-participant-completion-simple ..... SUCCESS [  0.225 s]
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 01:16 min
[INFO] Finished at: 2019-02-09T11:01:57-08:00
[INFO] Final Memory: 203M/660M
[INFO] ------------------------------------------------------------------------

```

## Build Console App - send and receive messages to Service Bus using JMS

### Create and Configure Azure Service Bus

Log into Azure using CLI

```bash
az login
```
Set environment variables for binding secrets at runtime, 
particularly Azure Resource Group name and Azure Service Bus info. 
You can 
export them to your local environment, say using the supplied
Bash shell script template.

```bash
cd helloworld-jms
mkdir .scripts
cp set-env-variables-template.sh .scripts/set-env-variables.sh
```

Modify `.scripts/set-env-variables.sh` and set Azure Resource Group name, 
and Azure Service Bus info. Then, set environment variables:
 
```bash
source .scripts/set-env-variables.sh
```

Create Azure Service Bus:

```bash

az group create --name ${RESOURCEGROUP_NAME} \
    --location ${REGION}
    
az servicebus namespace create \
    --name  ${DEFAULT_SBNAMESPACE} \
    --resource-group ${RESOURCEGROUP_NAME}

az servicebus queue create \
    --name ${SB_QUEUE} \
    --namespace-name ${DEFAULT_SBNAMESPACE} \
    --resource-group ${RESOURCEGROUP_NAME}

az servicebus queue authorization-rule create \
    --name ${SB_SAS_POLICY} \
    --namespace-name ${DEFAULT_SBNAMESPACE} \
    --queue-name ${SB_QUEUE} \
    --resource-group ${RESOURCEGROUP_NAME} \
    --rights Listen Send

az servicebus queue authorization-rule keys list \
    --name ${SB_SAS_POLICY} \
    --namespace-name ${DEFAULT_SBNAMESPACE} \
    --queue-name ${SB_QUEUE} \
    --resource-group ${RESOURCEGROUP_NAME}
                                                
```

From the values displayed for the keys, grab the 
<b>primarykey</b> value. Open the .scripts/set-env-variables.sh 
file and set the primaryKey as value for variable DEFAULT_PASSWORD.

Export environment variables:

```bash
. .scripts/set-env-variables.sh
```

### Build and Run Console App

Use Maven to build and run:

```bash
mvn clean compile exec:java -Dexec.cleanupDaemonThreads=false

[INFO] Scanning for projects...
[INFO] 
[INFO] ------------------------------------------------------------------------
[INFO] Building Quickstart: helloworld-jms 14.0.1.Final
[INFO] ------------------------------------------------------------------------
...
...
[INFO] --- exec-maven-plugin:1.6.0:java (default-cli) @ helloworld-jms ---
SLF4J: Failed to load class "org.slf4j.impl.StaticLoggerBinder".
SLF4J: Defaulting to no-operation (NOP) logger implementation
SLF4J: See http://www.slf4j.org/codes.html#StaticLoggerBinder for further details.
Feb 10, 2019 9:28:31 AM org.jboss.as.quickstarts.jms.HelloWorldJMSClient main
INFO: Attempting to acquire connection factory "SBCF"
Feb 10, 2019 9:28:31 AM org.jboss.as.quickstarts.jms.HelloWorldJMSClient main
INFO: Found connection factory "SBCF" in JNDI
Feb 10, 2019 9:28:31 AM org.jboss.as.quickstarts.jms.HelloWorldJMSClient main
INFO: Attempting to acquire destination "QUEUE"
Feb 10, 2019 9:28:31 AM org.jboss.as.quickstarts.jms.HelloWorldJMSClient main
INFO: Found destination "QUEUE" in JNDI
Feb 10, 2019 9:28:37 AM org.jboss.as.quickstarts.jms.HelloWorldJMSClient main
INFO: Sending 1 messages with content: Hello, World!
Feb 10, 2019 9:28:37 AM org.jboss.as.quickstarts.jms.HelloWorldJMSClient main
INFO: Received message with content Hello, World!
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 8.763 s
[INFO] Finished at: 2019-02-10T09:28:38-08:00
[INFO] Final Memory: 33M/401M
[INFO] ------------------------------------------------------------------------
```
## Migrate a message driven enterprise bean to Azure


### Prepare Environment

Change directory to MDB:

```bash
cd ../helloworld-mdb
```

Set environment variables for binding secrets at runtime, 
particularly Azure Resource Group name and Azure Service Bus info. 
You can 
export them to your local environment, say using the supplied
Bash shell script template.

```bash
cp set-env-variables-template.sh .scripts/set-env-variables.sh
```

Modify `.scripts/set-env-variables.sh` and set Azure Resource Group name, 
Azure Service Bus info and App Service Linux info. You can copy 
most of these values from the script of 
the previous exercise
`../helloworld-jms/.scripts/set-env-variables.sh` and add App 
Service Linux info. 

Then, set environment variables:
 
```bash
source .scripts/set-env-variables.sh
```

### Deploy App to App Service Linux

Add [Maven Plugin for Azure App Service](https://github.com/Microsoft/azure-maven-plugins/blob/develop/azure-webapp-maven-plugin/README.md) configuration to POM.xml and deploy
Message-Driven Bean to WildFly in App Service Linux:

```xml    
<plugins> 

    <!--*************************************************-->
    <!-- Deploy to WildFly in App Service Linux          -->
    <!--*************************************************-->
       
    <plugin>
        <groupId>com.microsoft.azure</groupId>
        <artifactId>azure-webapp-maven-plugin</artifactId>
        <version>1.5.3</version>
        <configuration>
    
            <!-- Web App information -->
           <resourceGroup>${RESOURCEGROUP_NAME}</resourceGroup>
           <appServicePlanName>${WEBAPP_PLAN_NAME}</appServicePlanName>
            <appName>${WEBAPP_NAME}</appName>
            <region>${REGION}</region>
    
            <!-- Java Runtime Stack for Web App on Linux-->
            <linuxRuntime>wildfly 14-jre8</linuxRuntime>
            
            <appSettings>
                <property>
                    <name>DEFAULT_SBNAMESPACE</name>
                    <value>${DEFAULT_SBNAMESPACE}</value>
                </property>
                <property>
                    <name>SB_SAS_POLICY</name>
                    <value>${SB_SAS_POLICY}</value>
                </property>
                <property>
                    <name>SB_SAS_KEY</name>
                    <value>${SB_SAS_KEY}</value>
                </property>
                <property>
                    <name>PROVIDER_URL</name>
                    <value>${PROVIDER_URL}</value>
                </property>
                <property>
                    <name>SB_QUEUE</name>
                    <value>${SB_QUEUE}</value>
                </property>
            </appSettings>
        </configuration>
    </plugin>
    ...
</plugins>
```

Build and Deploy Message-Driven Bean to App Service Linux:

```bash
mvn package
[INFO] Scanning for projects...
[INFO] 
[INFO] ------------------------------------------------------------------------
[INFO] Building Quickstart: helloworld-mdb 14.0.1.Final
[INFO] ------------------------------------------------------------------------
[INFO] 
...
...
[INFO] --- maven-war-plugin:3.2.2:war (default-war) @ helloworld-mdb ---
[INFO] Packaging webapp
[INFO] Assembling webapp [helloworld-mdb] in [/Users/selvasingh/migrate-java-ee-app-to-azure-2/quickstart/helloworld-mdb/target/helloworld-mdb]
[INFO] Processing war project
[INFO] Copying webapp resources [/Users/selvasingh/migrate-java-ee-app-to-azure-2/quickstart/helloworld-mdb/src/main/webapp]
[INFO] Webapp assembled in [84 msecs]
[INFO] Building war: /Users/selvasingh/migrate-java-ee-app-to-azure-2/quickstart/helloworld-mdb/target/helloworld-mdb.war
[INFO] 
[INFO] --- maven-source-plugin:3.0.1:jar-no-fork (attach-sources) @ helloworld-mdb ---
[INFO] Building jar: /Users/selvasingh/migrate-java-ee-app-to-azure-2/quickstart/helloworld-mdb/target/helloworld-mdb-sources.jar
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 3.908 s
[INFO] Finished at: 2019-02-10T11:37:03-08:00
[INFO] Final Memory: 34M/413M
[INFO] ------------------------------------------------------------------------


mvn azure-webapp:deploy

[INFO] 
[INFO] ------------------------------------------------------------------------
[INFO] Building Quickstart: helloworld-mdb 14.0.1.Final
[INFO] ------------------------------------------------------------------------
[INFO] 
[INFO] --- azure-webapp-maven-plugin:1.5.3:deploy (default-cli) @ helloworld-mdb ---
...
...
[INFO] Authenticate with Azure CLI 2.0
[INFO] Target Web App doesn't exist. Creating a new one...
[INFO] Creating App Service Plan 'helloworld-mdb-appservice-plan'...
[INFO] Successfully created App Service Plan.
[INFO] Successfully created Web App.
[INFO] Trying to deploy artifact to helloworld-mdb...
[INFO] Deploying the war file...
[INFO] Successfully deployed the artifact to https://helloworld-mdb.azurewebsites.net
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 02:15 min
[INFO] Finished at: 2019-02-10T11:41:06-08:00
[INFO] Final Memory: 55M/362M
[INFO] ------------------------------------------------------------------------

```

### Configure JMS Resource Adapter ( JMS RA)

There are a few steps to configure a JMS RA which will enable 
Java EJBs to configure a 
remote JMS connection factory and queue. 
This remote setup will point to
Azure Service Bus, using the [Apache Qpid JMS Provider](https://qpid.apache.org/components/jms/index.html) 
for the AMQP protocol. 

#### Step 1: Understand How to configure WildFly

In App Service, each instance of an app server is stateless. Therefore, each instance must be 
configured on startup to support a Wildfly configuration needed by your application. You can configure at 
startup by supplying a startup Bash script that calls [JBoss/WildFly CLI commands](https://docs.jboss.org/author/display/WFLY/Command+Line+Interface) to setup data sources, messaging 
 providers and any other dependencies. We will create a startup.sh script and place it in the `/home` 
 directory of the Web app. The script will:
 
Install a WildFly Generic JMS Provider Module and Configure JMS RA. A `module.xml` 
describes the Generic JMS Provider Module:

```xml
<module xmlns="urn:jboss:module:1.1" name="org.jboss.genericjms.provider"> 
  <resources> 
      <resource-root path="proton-j-<version>.jar"/> 
      <resource-root path="qpid-jms-client-<version>jar"/>
      <resource-root path="slf4j-log4j12-<version>jar"/>
      <resource-root path="slf4j-api-<version>jar"/>
      <resource-root path="log4j-<version>jar"/>      
      <resource-root path="netty-buffer-<version>.jar" />
      <resource-root path="netty-codec-<version>.jar" />
      <resource-root path="netty-codec-http-<version>.jar" />
      <resource-root path="netty-common-<version>.jar" />
      <resource-root path="netty-handler-<version>.jar" />
      <resource-root path="netty-resolver-<version>.jar" />
      <resource-root path="netty-transport-<version>.jar" />
      <resource-root path="netty-transport-native-epoll-<version>-linux-x86_64.jar" />
      <resource-root path="netty-transport-native-kqueue-<version>-osx-x86_64.jar" />
      <resource-root path="netty-transport-native-unix-common-<version>.jar" /> 
      <resource-root path="qpid-jms-discovery-<version>jar" />
  </resources> 

   <dependencies> 
      <module name="javax.api"/> 
      <module name="javax.jms.api"/> 
  </dependencies> 
</module>
```

Generate a `jndi.properties` file on the fly:

```bash
echo "Generating jndi.properties file in /home/site/deployments/tools directory"
echo "connectionfactory.SBF=amqps://${DEFAULT_SBNAMESPACE}.servicebus.windows.net?amqp.idleTimeout=120000&jms.username=${SB_SAS_POLICY}&jms.password=${SB_SAS_KEY}" > /home/site/deployments/tools/jndi.properties
echo "queue.jmstestqueue=${SB_QUEUE}" >> /home/site/deployments/tools/jndi.properties
echo "====== contents of /home/site/deployments/tools/jndi.properties ======"
cat /home/site/deployments/tools/jndi.properties
echo "====== EOF /home/site/deployments/tools/jndi.properties ======"
```

Copy all binary JARs, `module file` and generated `jndi.properties` file to WildFly config location:

```bash
mkdir /opt/jboss/wildfly/modules/system/layers/base/org/jboss/genericjms/provider
mkdir /opt/jboss/wildfly/modules/system/layers/base/org/jboss/genericjms/provider/main
cp  /home/site/deployments/tools/*.jar /opt/jboss/wildfly/modules/system/layers/base/org/jboss/genericjms/provider/main/
cp /home/site/deployments/tools/module.xml /opt/jboss/wildfly/modules/system/layers/base/org/jboss/genericjms/provider/main/
cp /home/site/deployments/tools/jndi.properties /opt/jboss/wildfly/standalone/configuration/
```

Add a Generic JMS Provider Module:

```bash
/subsystem=ee:list-add(name=global-modules, value={"name" => "org.jboss.genericjms.provider", "slot" =>"main"}
/subsystem=naming/binding="java:global/remoteJMS":add(binding-type=external-context,module=org.jboss.genericjms.provider,class=javax.naming.InitialContext,environment=[java.naming.factory.initial=org.apache.qpid.jms.jndi.JmsInitialContextFactory,org.jboss.as.naming.lookup.by.string=true,java.naming.provider.url=/home/site/deployments/tools/jndi.properties])
/subsystem=resource-adapters/resource-adapter=generic-ra:add(module=org.jboss.genericjms,transaction-support=XATransaction)
/subsystem=resource-adapters/resource-adapter=generic-ra/connection-definitions=sbf-cd:add(class-name=org.jboss.resource.adapter.jms.JmsManagedConnectionFactory, jndi-name=java:/jms/SBF)
/subsystem=resource-adapters/resource-adapter=generic-ra/connection-definitions=sbf-cd/config-properties=ConnectionFactory:add(value=SBF)
/subsystem=resource-adapters/resource-adapter=generic-ra/connection-definitions=sbf-cd/config-properties=JndiParameters:add(value="java.naming.factory.initial=org.apache.qpid.jms.jndi.JmsInitialContextFactory;java.naming.provider.url=/home/site/deployments/tools/jndi.properties")
/subsystem=resource-adapters/resource-adapter=generic-ra/connection-definitions=sbf-cd:write-attribute(name=security-application,value=true)
/subsystem=ejb3:write-attribute(name=default-resource-adapter-name, value=generic-ra)
```

A server reload may be required for the changes to take effect:

```bash
reload --use-current-server-config=true
```

These JBoss CLI commands, WildFly/JBoss Generic JMS Provider Module description `module.xml` 
and JARs are available in
[quickstart/helloworld-mdb/.scripts](https://github.com/Azure-Samples/migrate-Java-EE-app-to-azure-2/tree/master/quickstart/helloworldmdb/.scripts) 

Also, you can directly download Qpid and Proton-j libraries from 
[Apache Qpid JMS Provider](https://qpid.apache.org/components/jms/index.html) 
for the AMQP protocol.

#### Step 2 - Upload Startup and Binary Artifacts to App through FTP

##### Get FTP Deployment Credentials

Use Azure CLI to get FTP deployment credentials:

```bash
az webapp deployment list-publishing-profiles -g ${RESOURCEGROUP_NAME} -n ${WEBAPP_NAME}
...
...
{
   ...
   ...
    "profileName": "helloworld-mdb - FTP",
    "publishMethod": "FTP",
    "publishUrl": "ftp://waws-prod-mwh-007.ftp.azurewebsites.windows.net/site/wwwroot",
    "userName": "helloworld-mdb\\$helloworld-mdb",
    "userPWD": ================ MASKED ======================,
    "webSystem": "WebSites"
}
   
```

Store FTP host name, say `waws-prod-mwh-007.ftp.azurewebsites.windows.net`, 
user name and user password in .scripts/set-env-variables.sh file.

##### Upload Startup and Binary Artifacts to App through FTP

Open an FTP connection to App Service Linux to upload artifacts:

```bash
cd .scripts

# open FTP
ftp
ftp> open waws-prod-mwh-007.ftp.azurewebsites.windows.net
Trying 52.183.36.81...
Connected to waws-prod-mwh-007.drip.azurewebsites.windows.net.
220 Microsoft FTP Service
Name (waws-prod-mwh-007.ftp.azurewebsites.windows.net:selvasingh): helloworld-mdb\\$helloworld-mdb
331 Password required
Password: 
230 User logged in.
Remote system type is Windows_NT.
ftp> ascii
200 Type set to A.
ftp> passive
Passive mode: off; fallback to active mode: off.

# upload startup.sh

ftp> put startup.sh
local: startup.sh remote: startup.sh
200 EPRT command successful.
125 Data connection already open; Transfer starting.
100% |*********************************************|  1291      211.78 KiB/s    --:-- ETA
226 Transfer complete.
1291 bytes sent in 00:00 (42.12 KiB/s)

# move to tools directory

ftp> cd site/deployments/tools
250 CWD command successful.

# upload commands.cli and module.xml

ftp> put commands.cli
local: commands.cli remote: commands.cli
200 EPRT command successful.
125 Data connection already open; Transfer starting.
100% |*********************************************|  1477      242.49 KiB/s    --:-- ETA
226 Transfer complete.
1477 bytes sent in 00:00 (48.30 KiB/s)
ftp> put module.xml
local: module.xml remote: module.xml
200 EPRT command successful.
125 Data connection already open; Transfer starting.
100% |*********************************************|  1280      206.06 KiB/s    --:-- ETA
226 Transfer complete.
1280 bytes sent in 00:00 (33.16 KiB/s)

# upload JARs

ftp> binary
200 Type set to I.
ftp> mput *.jar
mput log4j-1.2.17.jar [anpqy?]? y
229 Entering Extended Passive Mode (|||10103|)
125 Data connection already open; Transfer starting.
100% |*********************************************|   478 KiB    1.73 MiB/s    00:00 ETA
226 Transfer complete.
489884 bytes sent in 00:00 (1.40 MiB/s)
mput netty-buffer-4.1.32.Final.jar [anpqy?]? y
229 Entering Extended Passive Mode (|||10105|)
125 Data connection already open; Transfer starting.
100% |*********************************************|   271 KiB  790.62 KiB/s    00:00 ETA
226 Transfer complete.
277778 bytes sent in 00:00 (612.65 KiB/s)
mput netty-codec-4.1.32.Final.jar [anpqy?]? y
229 Entering Extended Passive Mode (|||10101|)
125 Data connection already open; Transfer starting.
100% |*********************************************|   309 KiB    1.42 MiB/s    00:00 ETA
226 Transfer complete.
316671 bytes sent in 00:00 (1.20 MiB/s)
mput netty-codec-http-4.1.32.Final.jar [anpqy?]? y
229 Entering Extended Passive Mode (|||10106|)
125 Data connection already open; Transfer starting.
100% |*********************************************|   550 KiB    1.88 MiB/s    00:00 ETA
226 Transfer complete.
563215 bytes sent in 00:00 (1.55 MiB/s)
mput netty-common-4.1.32.Final.jar [anpqy?]? y
229 Entering Extended Passive Mode (|||10104|)
125 Data connection already open; Transfer starting.
100% |*********************************************|   573 KiB    2.03 MiB/s    00:00 ETA
226 Transfer complete.
586829 bytes sent in 00:00 (1.65 MiB/s)
mput netty-handler-4.1.32.Final.jar [anpqy?]? y
229 Entering Extended Passive Mode (|||10108|)
125 Data connection already open; Transfer starting.
100% |*********************************************|   410 KiB    1.72 MiB/s    00:00 ETA
226 Transfer complete.
420485 bytes sent in 00:00 (1.36 MiB/s)
mput netty-resolver-4.1.32.Final.jar [anpqy?]? y
229 Entering Extended Passive Mode (|||10107|)
125 Data connection already open; Transfer starting.
100% |*********************************************| 32800        5.49 MiB/s    00:00 ETA
226 Transfer complete.
32800 bytes sent in 00:00 (325.36 KiB/s)
mput netty-transport-4.1.32.Final.jar [anpqy?]? y
229 Entering Extended Passive Mode (|||10109|)
125 Data connection already open; Transfer starting.
100% |*********************************************|   452 KiB    1.69 MiB/s    00:00 ETA
226 Transfer complete.
463581 bytes sent in 00:00 (1.40 MiB/s)
mput netty-transport-native-epoll-4.1.32.Final-linux-x86_64.jar [anpqy?]? y
229 Entering Extended Passive Mode (|||10110|)
125 Data connection already open; Transfer starting.
100% |*********************************************|   137 KiB    1.85 MiB/s    00:00 ETA
226 Transfer complete.
141017 bytes sent in 00:00 (521.44 KiB/s)
mput netty-transport-native-kqueue-4.1.32.Final-osx-x86_64.jar [anpqy?]? y
229 Entering Extended Passive Mode (|||10111|)
125 Data connection already open; Transfer starting.
100% |*********************************************|   107 KiB   18.22 MiB/s    00:00 ETA
226 Transfer complete.
109800 bytes sent in 00:00 (143.52 KiB/s)
mput netty-transport-native-unix-common-4.1.32.Final.jar [anpqy?]? y
229 Entering Extended Passive Mode (|||10112|)
125 Data connection already open; Transfer starting.
100% |*********************************************| 33470        5.47 MiB/s    00:00 ETA
226 Transfer complete.
33470 bytes sent in 00:00 (366.26 KiB/s)
mput proton-j-0.31.0.jar [anpqy?]? y
229 Entering Extended Passive Mode (|||10114|)
125 Data connection already open; Transfer starting.
100% |*********************************************|   719 KiB    1.93 MiB/s    00:00 ETA
226 Transfer complete.
736444 bytes sent in 00:00 (1.67 MiB/s)
mput qpid-jms-client-0.40.0.jar [anpqy?]? y
229 Entering Extended Passive Mode (|||10113|)
125 Data connection already open; Transfer starting.
100% |*********************************************|   729 KiB    1.89 MiB/s    00:00 ETA
226 Transfer complete.
747044 bytes sent in 00:00 (1.63 MiB/s)
mput qpid-jms-discovery-0.40.0.jar [anpqy?]? y
229 Entering Extended Passive Mode (|||10115|)
125 Data connection already open; Transfer starting.
100% |*********************************************| 40531       21.01 MiB/s    00:00 ETA
226 Transfer complete.
40531 bytes sent in 00:00 (360.08 KiB/s)
mput slf4j-api-1.7.25.jar [anpqy?]? y
229 Entering Extended Passive Mode (|||10116|)
125 Data connection already open; Transfer starting.
100% |*********************************************| 41203       59.08 MiB/s    00:00 ETA
226 Transfer complete.
41203 bytes sent in 00:00 (338.90 KiB/s)
mput slf4j-log4j12-1.7.25.jar [anpqy?]? y
229 Entering Extended Passive Mode (|||10118|)
125 Data connection already open; Transfer starting.
100% |*********************************************| 12244        2.10 MiB/s    00:00 ETA
226 Transfer complete.
12244 bytes sent in 00:00 (169.29 KiB/s)
```

#### Step 4: Test the JBoss/WildFly Startup Script and CLI Commands to Configure JMS RA

You can test Bash script for configuring data source by running them on App Service Linux 
by [opening an SSH connection from your development machine](https://docs.microsoft.com/en-us/azure/app-service/containers/app-service-linux-ssh-support#open-ssh-session-from-remote-shell):

```bash
# ======== first terminal window =========
az webapp remote-connection create --resource-group ${RESOURCEGROUP_NAME} --name ${WEBAPP_NAME} &
[1] 63235
bash-3.2$ Auto-selecting port: 65428
SSH is available { username: root, password: Docker! }
Start your favorite client and connect to port 65428
Websocket tracing disabled, use --verbose flag to enable
Successfully connected to local server..

# ======== second terminal window ========
ssh root@localhost -p 65428
The authenticity of host '[localhost]:65428 ([127.0.0.1]:65428)' can't be established.
ECDSA key fingerprint is SHA256:u/VkSFAFjoO9EkBT4zl1pNoWAzWAUdUeRjaHnsXNXlM.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '[localhost]:65428' (ECDSA) to the list of known hosts.
root@localhost's password: 
  _____                               
  /  _  \ __________ _________   ____  
 /  /_\  \___   /  |  \_  __ \_/ __ \ 
/    |    \/    /|  |  /|  | \/\  ___/ 
\____|__  /_____ \____/ |__|    \___  >
        \/      \/                  \/ 
A P P   S E R V I C E   O N   L I N U X

Documentation: http://aka.ms/webapp-linux

54cfe2dfa970:/home# ls -al
total 12
drwxrwxrwx    2 nobody   nobody        4096 Feb 11 17:54 .
drwxr-xr-x   49 root     root          4096 Feb 10 19:40 ..
drwxrwxrwx    2 nobody   nobody           0 Feb 10 19:40 .mono
drwxrwxrwx    2 nobody   nobody           0 Feb 10 19:41 LogFiles
drwxrwxrwx    2 nobody   nobody           0 Feb 10 19:40 d43fc68fefbe78c2a087a46f
drwxrwxrwx    2 nobody   nobody           0 Feb 10 19:41 site
-rwxrwxrwx    1 nobody   nobody        1291 Feb 11 17:46 startup.sh
54cfe2dfa970:/home# 


#========= open a vi window to edit startup.sh ============
c315a18b39d2:/home# vi startup.sh

# ======== vi window =====================
echo "Generating jndi.properties file in /home/site/deployments/tools directory"^M
echo "connectionfactory.SBF=amqps://${DEFAULT_SBNAMESPACE}.servicebus.windows.net?amqp.idleTimeout=120000&jms.username=${SB_SAS_POLICY}&jms.password=${SB_SAS_KEY}" > /home/site/deployments/tools/jndi.properties^M
echo "queue.jmstestqueue=${SB_QUEUE}" >> /home/site/deployments/tools/jndi.properties^M
echo "====== contents of /home/site/deployments/tools/jndi.properties ======"^M
cat /home/site/deployments/tools/jndi.properties^M
echo "====== EOF /home/site/deployments/tools/jndi.properties ======"^M
mkdir /opt/jboss/wildfly/modules/system/layers/base/org/jboss/genericjms/provider^M
mkdir /opt/jboss/wildfly/modules/system/layers/base/org/jboss/genericjms/provider/main^M
cp  /home/site/deployments/tools/*.jar /opt/jboss/wildfly/modules/system/layers/base/org/jboss/gene
cp /home/site/deployments/tools/module.xml /opt/jboss/wildfly/modules/system/layers/base/org/jboss/
cp /home/site/deployments/tools/jndi.properties /opt/jboss/wildfly/standalone/configuration/^M
/opt/jboss/wildfly/bin/jboss-cli.sh -c --file=/home/site/deployments/tools/commands.cli^M
rm /home/site/deployments/tools/jndi.properties^M
echo "Deleted /home/site/deployments/tools/jndi.properties"

## === remove those '^M' end of line characters and save the file
```

There are alternate ways to remove the end of line characters ([see](http://marcelog.github.io/articles/mac_newline_to_unix_eol.html)).

##### Test the startup.sh script

In the SSH window, execute `startup.sh`:

```bash
54cfe2dfa970:/home# source startup.sh
Generating jndi.properties file in /home/site/deployments/tools directory
====== contents of /home/site/deployments/tools/jndi.properties ======
connectionfactory.SBF=amqps://jmsservice}.servicebus.windows.net?amqp.idleTimeout=120000&jms.username=ListenAndSend&jms.password=[MASKED]
queue.jmstestqueue=
====== EOF /home/site/deployments/tools/jndi.properties ======
Picked up _JAVA_OPTIONS: -Djava.net.preferIPv4Stack=true
{"outcome" => "success"}
{"outcome" => "success"}
{"outcome" => "success"}
{"outcome" => "success"}
{"outcome" => "success"}
{"outcome" => "success"}
{
    "outcome" => "success",
    "response-headers" => {
        "operation-requires-reload" => true,
        "process-state" => "reload-required"
    }
}
{
    "outcome" => "success",
    "response-headers" => {"process-state" => "reload-required"}
}
Deleted /home/site/deployments/tools/jndi.properties
```
#### Step 5: Restart the remote WildFly app server
     
 Use Azure CLI to restart the remote WildFly app server:
    
 ```bash
 az webapp stop -g ${RESOURCEGROUP_NAME} -n ${WEBAPP_NAME}
 az webapp start -g ${RESOURCEGROUP_NAME} -n ${WEBAPP_NAME}
 ```

#### Step 6: Stream WildFly/JBoss logs to a dev machine

Configure logs for the deployed Java Web 
app in App Service Linux:

```bash
az webapp log config --name ${WEBAPP_NAME} \
 --resource-group ${RESOURCEGROUP_NAME} \
  --web-server-logging filesystem
```

Open Java Web app remote log stream from a local machine:

```bash
az webapp log tail --name ${WEBAPP_NAME} \
 --resource-group ${RESOURCEGROUP_NAME}
```

### Open the Message-Driven Enterprise Bean on Azure

Open the Web app on App Service Linux:

```bash
https://helloworld-mdb.azurewebsites.net
```

![](./media/helloworld-mdb.jpg)

On the log stream from App Service Linux, you will see:

```bash
2019-02-12 06:37:47,821 INFO  [org.apache.qpid.jms.sasl.SaslMechanismFinder] (AmqpProvider :(2):[amqps://jmsservice.servicebus.windows.net:-1]) Best match for SASL auth was: SASL-PLAIN
2019-02-12 06:37:47,828 INFO  [org.apache.qpid.jms.JmsConnection] (AmqpProvider :(2):[amqps://jmsservice.servicebus.windows.net:-1]) Connection ID:48eae295-9d89-4aa6-85e8-f26a9b43147e:1 connected to remote Broker: amqps://jmsservice.servicebus.windows.net
2019-02-12T06:37:47.822173661Z 06:37:47,821 INFO  [org.apache.qpid.jms.sasl.SaslMechanismFinder] (AmqpProvider :(2):[amqps://jmsservice.servicebus.windows.net:-1]) Best match for SASL auth was: SASL-PLAIN
2019-02-12T06:37:47.830453730Z 06:37:47,828 INFO  [org.apache.qpid.jms.JmsConnection] (AmqpProvider :(2):[amqps://jmsservice.servicebus.windows.net:-1]) Connection ID:48eae295-9d89-4aa6-85e8-f26a9b43147e:1 connected to remote Broker: amqps://jmsservice.servicebus.windows.net
```

### Additional Info

For additional info, please refer to: 
 
 - [Deploying Generic JMS RA Adapter in JBoss/WildFly](https://access.redhat.com/documentation/en-us/red_hat_jboss_enterprise_application_platform/7.1/html/configuring_messaging/resource_adapters#deploy_configure_generic_jms_resource_adapter)
 - [JBoss/WildFly CLI Guide](https://docs.jboss.org/author/display/WFLY/Command+Line+Interface)
 - [Open SSH session from your development machine to App Service Linux](https://docs.microsoft.com/en-us/azure/app-service/containers/app-service-linux-ssh-support#open-ssh-session-from-remote-shell)

## Migrate Java Enterprise App that uses WebSockets

Change directory to the WebSocket app directory:

```bash
cd ../websocket-hello
```

Set environment variables for binding secrets at runtime, 
particularly Azure Resource Group name and App Service Linux info. 
You can 
export them to your local environment, say using the supplied
Bash shell script template.

```bash
mkdir .scripts
cp set-env-variables-template.sh .scripts/set-env-variables.sh
```

Modify `.scripts/set-env-variables.sh` and set Azure Resource Group name, 
and App Service Linux info.

Then, set environment variables:
 
```bash
source .scripts/set-env-variables.sh
```

### Deploy App to App Service Linux

Add [Maven Plugin for Azure App Service](https://github.com/Microsoft/azure-maven-plugins/blob/develop/azure-webapp-maven-plugin/README.md) configuration to POM.xml and deploy
Message-Driven Bean to WildFly in App Service Linux:

```xml    
<plugins> 

    <!--*************************************************-->
    <!-- Deploy to WildFly in App Service Linux          -->
    <!--*************************************************-->
       
    <plugin>
        <groupId>com.microsoft.azure</groupId>
        <artifactId>azure-webapp-maven-plugin</artifactId>
        <version>1.5.3</version>
        <configuration>
    
            <!-- Web App information -->
           <resourceGroup>${RESOURCEGROUP_NAME}</resourceGroup>
           <appServicePlanName>${WEBAPP_PLAN_NAME}</appServicePlanName>
            <appName>${WEBAPP_NAME}</appName>
            <region>${REGION}</region>
    
            <!-- Java Runtime Stack for Web App on Linux-->
            <linuxRuntime>wildfly 14-jre8</linuxRuntime>
            
        </configuration>
    </plugin>
    ...
</plugins>
```

Build and Deploy Message-Driven Bean to App Service Linux:

```bash
mvn package
[INFO] Scanning for projects...
[INFO] 
[INFO] ------------------------------------------------------------------------
[INFO] Building Quickstart: websocket-hello 14.0.1.Final
[INFO] ------------------------------------------------------------------------
[INFO] 
...
...
[INFO] --- maven-war-plugin:3.2.2:war (default-war) @ websocket-hello ---
[INFO] Packaging webapp
[INFO] Assembling webapp [websocket-hello] in [/Users/selvasingh/migrate-java-ee-app-to-azure-2/quickstart/websocket-hello/target/websocket-hello]
[INFO] Processing war project
[INFO] Copying webapp resources [/Users/selvasingh/migrate-java-ee-app-to-azure-2/quickstart/websocket-hello/src/main/webapp]
[INFO] Webapp assembled in [54 msecs]
[INFO] Building war: /Users/selvasingh/migrate-java-ee-app-to-azure-2/quickstart/websocket-hello/target/websocket-hello.war
[INFO] 
[INFO] --- maven-source-plugin:3.0.1:jar-no-fork (attach-sources) @ websocket-hello ---
[INFO] Building jar: /Users/selvasingh/migrate-java-ee-app-to-azure-2/quickstart/websocket-hello/target/websocket-hello-sources.jar
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 3.444 s
[INFO] Finished at: 2019-02-11T22:58:35-08:00
[INFO] Final Memory: 27M/318M
[INFO] ------------------------------------------------------------------------

mvn azure-webapp:deploy

mvn azure-webapp:deploy
[INFO] Scanning for projects...
[INFO] 
[INFO] ------------------------------------------------------------------------
[INFO] Building Quickstart: websocket-hello 14.0.1.Final
[INFO] ------------------------------------------------------------------------
[INFO] 
[INFO] --- azure-webapp-maven-plugin:1.5.3:deploy (default-cli) @ websocket-hello ---
[INFO] Authenticate with Azure CLI 2.0
[INFO] Target Web App doesn't exist. Creating a new one...
[INFO] Creating App Service Plan 'websocket-hello-app-appservice-plan'...
[INFO] Successfully created App Service Plan.
[INFO] Successfully created Web App.
[INFO] Trying to deploy artifact to websocket-hello-app...
[INFO] Deploying the war file...
[INFO] Successfully deployed the artifact to https://websocket-hello-app.azurewebsites.net
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 01:41 min
[INFO] Finished at: 2019-02-11T23:03:56-08:00
[INFO] Final Memory: 57M/366M
[INFO] ------------------------------------------------------------------------

```

### Open the Migrated App on App Service Linux

```bash
open https://websocket-hello-app.azurewebsites.net
```

![](./media/websocket-hello.jpg)



## Congratulations!

Congratulations!! You migrated 
existing Java enterprise workloads to Azure, aka app to App Service Linux and 
app's messaging system to Azure Service Bus.

## Resources

- [Java Enterprise Guide for App Service on Linux](https://docs.microsoft.com/en-us/azure/app-service/containers/app-service-java-enterprise)
- [Maven Plugin for Azure App Service](https://docs.microsoft.com/en-us/java/api/overview/azure/maven/azure-webapp-maven-plugin/readme?view=azure-java-stable)
- [Deploying Generic JMS RA Adapter in JBoss/WildFly](https://access.redhat.com/documentation/en-us/red_hat_jboss_enterprise_application_platform/7.1/html/configuring_messaging/resource_adapters#deploy_configure_generic_jms_resource_adapter)
- [JBoss/WildFly CLI Guide](https://docs.jboss.org/author/display/WFLY/Command+Line+Interface)
- [Opening an SSH connection from your development machine](https://docs.microsoft.com/en-us/azure/app-service/containers/app-service-linux-ssh-support#open-ssh-session-from-remote-shell)
- [Azure for Java Developers](https://docs.microsoft.com/en-us/java/azure/)

---

This project has adopted 
the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/). 
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or 
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) 
with any additional 
questions or comments.
