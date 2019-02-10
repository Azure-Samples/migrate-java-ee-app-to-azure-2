---
services: app-service, service bus queue
platforms: java
author: selvasingh, sadigopu
---

# Migrate 
This guide walks you through the process of migrating an 
existing Java EE workload to Azure, aka:
 
- Java EE app to App Service Linux and 
- App's messaging queue moved to Azure Service Bus 

## Table of Contents
 * [Migrate Java Messaging to to Azure](#migrate-java-ee-app-to-azure)
      * [What you will migrate to cloud](#what-you-will-migrate-to-cloud)
      * [What you will need](#what-you-will-need)
      * [Getting Started](#getting-started)
         * [Step ONE - Clone and Prep](#step-one---clone-and-prep)
      * [Create Azure Servicebus](#Create Service Bus in Azure using Azure CLI)
        * [Add MySQL Profile](#add-mysql-profile)
## What you will migrate to cloud

You will migrate the Wildfly Quickstart helloworld-ejb application as 
sample webapp to demonstrate the enterprise scenario of sending & receiving messages
from a queue :

- Java EE 7
- JMS API
- JSR 345 Enterprise Java Beans 3.2 (EJB 3.2)

Upon migration, you will power the app using 
Azure Service Bus queue for its messaging.

## What you will need

In order to utilize services in cloud, you need 
an Azure subscription. If you do not already have an Azure 
subscription, you can activate your 
[MSDN subscriber benefits](https://azure.microsoft.com/pricing/member-offers/msdn-benefits-details/) 
or sign up for a 
[free Azure account]((https://azure.microsoft.com/pricing/free-trial/)).

In addition, you will need the following:

| [Azure CLI](http://docs.microsoft.com/cli/azure/overview) 
| [Java 8](https://www.azul.com/downloads/azure-only/zulu/) 
| [Maven 3](http://maven.apache.org/) 
|
## Getting Started

You can start from scratch and complete each step, or 
you can bypass basic setup steps that you are already 
familiar with. Either way, you will end up with working code.
This sample is a precursor to the MDB sample we will migrate
soon, in that it provides the background on JMS API

### Step ONE - Clone and Prep

The step for Cloning the repo is needed only once, as it
will fetch all the WildFly samples that we will migrate
as part of this workshop

```bash
git clone --recurse-submodules https://github.com/Azure-Samples/migrate-java-ee-app-to-azure-2
cd migrate-Java-EE-app-to-azure-2
yes | cp -rf .prep/* .

cd quickstart/helloworld-mdb
$ mvn package -Dmaven.test.skip=true
[INFO] Scanning for projects...
[INFO]
[INFO] ---------------< org.wildfly.quickstarts:helloworld-mdb >---------------
[INFO] Building Quickstart: helloworld-mdb 14.0.1.Final
[INFO] --------------------------------[ war ]---------------------------------
[INFO]
[INFO] --- maven-enforcer-plugin:3.0.0-M2:enforce (enforce-java-version) @ helloworld-mdb ---
[INFO]
[INFO] --- maven-enforcer-plugin:3.0.0-M2:enforce (enforce-maven-version) @ helloworld-mdb ---
[INFO]
[INFO] --- buildnumber-maven-plugin:1.4:create (get-scm-revision) @ helloworld-mdb ---
[INFO] Executing: /bin/sh -c cd '/home/demouser/readyworkshop/migrate-java-ee-app-to-azure-2/quickstart/helloworld-mdb' && 'git' 'rev-parse' '--verify' 'HEAD'
[INFO] Working directory: /home/demouser/readyworkshop/migrate-java-ee-app-to-azure-2/quickstart/helloworld-mdb
[INFO] Storing buildNumber: 85353e73beca05c91f29ff27b761081f2da0b8d3 at timestamp: 1549278269613
[WARNING] Cannot get the branch information from the git repository:
Detecting the current branch failed: fatal: ref HEAD is not a symbolic ref

[INFO] Executing: /bin/sh -c cd '/home/demouser/readyworkshop/migrate-java-ee-app-to-azure-2/quickstart/helloworld-mdb' && 'git' 'rev-parse' '--verify' 'HEAD'
[INFO] Working directory: /home/demouser/readyworkshop/migrate-java-ee-app-to-azure-2/quickstart/helloworld-mdb
[INFO] Storing buildScmBranch: UNKNOWN
[INFO]
[INFO] --- maven-resources-plugin:3.1.0:resources (default-resources) @ helloworld-mdb ---
[INFO] Using 'UTF-8' encoding to copy filtered resources.
[INFO] skip non existing resourceDirectory /home/demouser/readyworkshop/migrate-java-ee-app-to-azure-2/quickstart/helloworld-mdb/src/main/resources
[INFO]
[INFO] --- maven-compiler-plugin:3.7.0:compile (default-compile) @ helloworld-mdb ---
[INFO] Changes detected - recompiling the module!
[INFO] Compiling 3 source files to /home/demouser/readyworkshop/migrate-java-ee-app-to-azure-2/quickstart/helloworld-mdb/target/classes
[INFO]
[INFO] --- maven-checkstyle-plugin:3.0.0:checkstyle (check-style) @ helloworld-mdb ---
[INFO] Starting audit...
Audit done.
[INFO]
[INFO] --- maven-resources-plugin:3.1.0:testResources (default-testResources) @ helloworld-mdb ---
[INFO] Not copying test resources
[INFO]
[INFO] --- maven-compiler-plugin:3.7.0:testCompile (default-testCompile) @ helloworld-mdb ---
[INFO] Not compiling test sources
[INFO]
[INFO] --- maven-surefire-plugin:2.22.0:test (default-test) @ helloworld-mdb ---
[INFO] Tests are skipped.
[INFO]
[INFO] --- maven-war-plugin:3.2.2:war (default-war) @ helloworld-mdb ---
[INFO] Packaging webapp
[INFO] Assembling webapp [helloworld-mdb] in [/home/demouser/readyworkshop/migrate-java-ee-app-to-azure-2/quickstart/helloworld-mdb/target/helloworld-mdb]
[INFO] Processing war project
[INFO] Copying webapp resources [/home/demouser/readyworkshop/migrate-java-ee-app-to-azure-2/quickstart/helloworld-mdb/src/main/webapp]
[INFO] Webapp assembled in [95 msecs]
[INFO] Building war: /home/demouser/readyworkshop/migrate-java-ee-app-to-azure-2/quickstart/helloworld-mdb/target/helloworld-mdb.war
[INFO]
[INFO] --- maven-source-plugin:3.0.1:jar-no-fork (attach-sources) @ helloworld-mdb ---
[INFO] Building jar: /home/demouser/readyworkshop/migrate-java-ee-app-to-azure-2/quickstart/helloworld-mdb/target/helloworld-mdb-sources.jar
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time:  8.423 s
[INFO] Finished at: 2019-02-04T11:04:35Z
[INFO] ------------------------------------------------------------------------

```

### Create Service Bus in Azure using Azure CLI
Login to Azure by using the 'az login' command and follow the instructions that give a device code to be entered in browser

```bash
az login
```
Set environment variables for binding secrets at runtime, 
particularly Azure resource group and Service bus details. You can 
 them to your local environment, say using the supplied
Bash shell script template.

```bash
cp set-env-variables-template.sh .scripts/set-env-variables.sh
```

Modify the environment variables in set-env-variables.sh. Set the values of DEFAULT_SBNAMESPACE, SB_QUEUE,
 SB_SAS_POLICY  to names with which a Servicebus namepace, queue within the namespace and SAS Policy for the queue will get created along with Send&Listen rights for given Policy;and then with the last "authorization-rule" CLI command, you will get the SAS Key and modify the set-env-variables.sh file once again. If there is existing Service Bus, you can skip the following CLI commands for creating it and fill the details directly

```bash
vi .scripts/set-env-variables.sh

. .scripts/set-env-variables.sh, 


az servicebus namespace create --name  ${DEFAULT_SBNAMESPACE} \
                               --resource-group ${RESOURCEGROUP_NAME}

az servicebus queue create --name ${SB_QUEUE} \
                           --namespace-name ${DEFAULT_SBNAMESPACE} \
                           --resource-group ${RESOURCEGROUP_NAME}

az servicebus queue authorization-rule create --name ${SB_SAS_POLICY} \
                                              --namespace-name ${DEFAULT_SBNAMESPACE} \
                                              --queue-name ${SB_QUEUE} \
                                              --resource-group ${RESOURCEGROUP_NAME} \
                                              --rights Listen Send

az servicebus queue authorization-rule keys list --name ${SB_SAS_POLICY} \
                                                 --namespace-name ${DEFAULT_SBNAMESPACE} \
                                                 --queue-name ${SB_QUEUE} \
                                                 --resource-group ${RESOURCEGROUP_NAME}
                                                
```

From the values displayed for the keys, grab the <b>primarykey</b> value. Open the .scripts/set-env-variables.sh file and set the primaryKey as value for variable SB_SAS_KEY.

********* IMPORTANT ********************************
Put the values into .scripts/jndi.properties file for key connectionfactory.SBF and queue. Encrypt  the SB_SAS_KEY before pasting it in, at any site for eg: https://www.url-encode-decode.com/

connectionfactory.SBF=amqps://${DEFAULT_SBNAMESPACE}.servicebus.windows.net?amqp.idleTimeout=120000&jms.username=<SB_SAS_POLICY>&jms.password=<encrypted SB_SAS_KEY>
queue.jmstestqueue=<SB_QUEUE>

******************************************************

```bash
vi .scripts/set-env-variables.sh
vi .scripts/jndi.properties
. .scripts/set-env-variables.sh
```

Add [Maven Plugin for Azure App Service](https://github.com/Microsoft/azure-maven-plugins/blob/develop/azure-webapp-maven-plugin/README.md) configuration to POM.xml and deploy
Pet Store to WildFly in App Service Linux:

```xml    
<plugins> 

    <!--*************************************************-->
    <!-- Deploy to WildFly in App Service Linux          -->
    <!--*************************************************-->
       
    <plugin>
        <groupId>com.microsoft.azure</groupId>
        <artifactId>azure-webapp-maven-plugin</artifactId>
        <version>1.5.1</version>
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

Deploy to App Service Linux:

```bash
mvn azure-webapp:deploy
```

Set ServiceBus details in the Web app environment as AppSettings :

```bash
az webapp config appsettings set \
 --resource-group ${RESOURCEGROUP_NAME} --name ${WEBAPP_NAME} \
 --settings \
 DEFAULT_SBNAMESPACE=${DEFAULT_SBNAMESPACE} \
 SB_SAS_POLICY=${SB_SAS_POLICY} \
 SB_SAS_KEY=${SB_SAS_KEY} \
 SB_QUEUE=${SB_QUEUE} \
 PROVIDER_URL=amqps://${DEFAULT_SBNAMESPACE}.servicebus.windows.net?amqp.idleTimeout=120000
   
```

#### Configure JMS Resource Adapter ( JMS RA)

There are few steps to configure a JMS RA which will enable Java EJBs to configure a 
remote JMS connection factory and queue. This remote setup is needed so as to point to
Azure servicebus, using the Apache QPId interface for AMQP protocol. 

##### Step 1: Understand How to configure WildFly

In App Service, each instance of an app server is stateless. Therefore, each instance must be 
configured on startup to support a Wildfly configuration needed by your application. You can configure at 
startup by supplying a startup Bash script that calls [JBoss/WildFly CLI commands](https://docs.jboss.org/author/display/WFLY/Command+Line+Interface) to setup data sources, messaging 
 providers and any other dependencies. We will create a startup.sh script and place it in the `/home` 
 directory of the Web app. The script will:
 
Install a WildFly Generic JMS Provider and Configure JMS RA :

Step 1 - Download and configure the QPId and Proton-j libraries as Generic JMS Provider

To use a generic JMS provider as Resource Adapter to Service Bus,
download Apache QPId JMS (AMQP 1.0) 
from https://qpid.apache.org/download.html and replace the placeholder <version>
in the module.xml to configure them for WildFly

Where `module.xml` describes the module:

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

Modify the pom.xml to include the dependency details on QPId

Step 2 - Upload the Artefacts to website through FTP

Open an FTP connection to App Service Linux to upload artifacts:

```bash
cd .scripts

ftp
ftp> open waws-prod-bay-063.ftp.azurewebsites.windows.net
Connected to waws-prod-bay-063.drip.azurewebsites.windows.net.
220 Microsoft FTP Service
Name (waws-prod-bay-063.ftp.azurewebsites.windows.net:demouser): testsreemdbssh\petstoreappcustomlogs
331 Password required
Password:
230 User logged in.
Remote system type is Windows_NT.
ftp> ascii
200 Type set to A.
ftp> passive
Passive mode on.

# Upload startup.sh to /home directory
ftp> put startup.sh
local: startup.sh remote: startup.sh
227 Entering Passive Mode (23,99,84,148,39,177).
125 Data connection already open; Transfer starting.
226 Transfer complete.
602 bytes sent in 0.00 secs (17.9410 MB/s)

# Upload CLI Commands, Module XML and QPId .jar files to /home/site/deployments/tools
ftp> cd site/deployments/tools
250 CWD command successful.
ftp> put commands.cli
local: commands.cli remote: commands.cli
227 Entering Passive Mode (23,99,84,148,39,173).
125 Data connection already open; Transfer starting.
226 Transfer complete.
1477 bytes sent in 0.00 secs (24.2858 MB/s)
ftp> put module.xml
local: module.xml remote: module.xml
227 Entering Passive Mode (23,99,84,148,39,176).
125 Data connection already open; Transfer starting.
226 Transfer complete.
1220 bytes sent in 0.00 secs (32.3190 MB/s)
ftp> put jndi.properties
local: jndi.properties remote: jndi.properties
227 Entering Passive Mode (23,99,84,148,39,178).
125 Data connection already open; Transfer starting.
226 Transfer complete.
205 bytes sent in 0.00 secs (6.9823 MB/s)
ftp> binary
200 Type set to I.

ftp> mput *.jar
mput log4j-1.2.17.jar? y
227 Entering Passive Mode (23,99,84,148,39,218).
125 Data connection already open; Transfer starting.
226 Transfer complete.
489884 bytes sent in 0.09 secs (5.2076 MB/s)
mput netty-buffer-4.1.32.Final.jar? y
227 Entering Passive Mode (23,99,84,148,39,215).
125 Data connection already open; Transfer starting.
226 Transfer complete.
277778 bytes sent in 0.07 secs (3.9120 MB/s)
mput netty-codec-4.1.32.Final.jar? y
227 Entering Passive Mode (23,99,84,148,39,219).
125 Data connection already open; Transfer starting.
226 Transfer complete.
316671 bytes sent in 0.07 secs (4.3485 MB/s)
mput netty-codec-http-4.1.32.Final.jar? y
227 Entering Passive Mode (23,99,84,148,39,220).
125 Data connection already open; Transfer starting.
226 Transfer complete.
563215 bytes sent in 0.09 secs (5.8851 MB/s)
mput netty-common-4.1.32.Final.jar?
227 Entering Passive Mode (23,99,84,148,39,221).
125 Data connection already open; Transfer starting.
226 Transfer complete.
586829 bytes sent in 0.09 secs (6.1445 MB/s)
mput netty-handler-4.1.32.Final.jar? y
227 Entering Passive Mode (23,99,84,148,39,222).
125 Data connection already open; Transfer starting.
226 Transfer complete.
420485 bytes sent in 0.07 secs (6.0012 MB/s)
mput netty-resolver-4.1.32.Final.jar?
227 Entering Passive Mode (23,99,84,148,39,224).
125 Data connection already open; Transfer starting.
226 Transfer complete.
32800 bytes sent in 0.00 secs (329.2686 MB/s)
mput netty-transport-4.1.32.Final.jar?
227 Entering Passive Mode (23,99,84,148,39,223).
125 Data connection already open; Transfer starting.
226 Transfer complete.
463581 bytes sent in 0.09 secs (4.8251 MB/s)
mput netty-transport-native-epoll-4.1.32.Final-linux-x86_64.jar?
227 Entering Passive Mode (23,99,84,148,39,226).
125 Data connection already open; Transfer starting.
226 Transfer complete.
141017 bytes sent in 0.05 secs (2.9692 MB/s)
mput netty-transport-native-kqueue-4.1.32.Final-osx-x86_64.jar?
227 Entering Passive Mode (23,99,84,148,39,225).
125 Data connection already open; Transfer starting.
226 Transfer complete.
109800 bytes sent in 0.02 secs (4.5883 MB/s)
mput netty-transport-native-unix-common-4.1.32.Final.jar?
227 Entering Passive Mode (23,99,84,148,39,227).
125 Data connection already open; Transfer starting.
226 Transfer complete.
33470 bytes sent in 0.00 secs (664.9891 MB/s)
mput proton-j-0.31.0.jar?
227 Entering Passive Mode (23,99,84,148,39,228).
125 Data connection already open; Transfer starting.
226 Transfer complete.
736444 bytes sent in 0.09 secs (7.6175 MB/s)
mput qpid-jms-client-0.40.0.jar?
227 Entering Passive Mode (23,99,84,148,39,229).
125 Data connection already open; Transfer starting.
226 Transfer complete.
747044 bytes sent in 0.09 secs (7.9253 MB/s)
mput qpid-jms-discovery-0.40.0.jar?
227 Entering Passive Mode (23,99,84,148,39,230).
125 Data connection already open; Transfer starting.
226 Transfer complete.
40531 bytes sent in 0.00 secs (339.0647 MB/s)
mput slf4j-api-1.7.25.jar?
227 Entering Passive Mode (23,99,84,148,39,231).
125 Data connection already open; Transfer starting.
226 Transfer complete.
41203 bytes sent in 0.00 secs (604.5268 MB/s)
mput slf4j-log4j12-1.7.25.jar? y
227 Entering Passive Mode (23,99,84,148,39,234).
125 Data connection already open; Transfer starting.
226 Transfer complete.
12244 bytes sent in 0.00 secs (343.4349 MB/s)


##### Step 4: Test the JBoss/WildFly CLI commands to configure JMS RA

You can test Bash script for configuring data source by running them on App Service Linux 
by [opening an SSH connection from your development machine](https://docs.microsoft.com/en-us/azure/app-service/containers/app-service-linux-ssh-support#open-ssh-session-from-remote-shell):

```bash
# ======== first terminal window =========
az webapp remote-connection create --resource-group ${RESOURCEGROUP_NAME} --name ${WEBAPP_NAME} &
[18] 7422
bash-3.2$ Auto-selecting port: 60029
SSH is available { username: root, password: Docker! }
Start your favorite client and connect to port 60029
Websocket tracing disabled, use --verbose flag to enable
Successfully connected to local server..

# ======== second terminal window ========
ssh root@localhost -p 60029
The authenticity of host '[localhost]:60029 ([127.0.0.1]:60029)' can't be established.
ECDSA key fingerprint is SHA256:Lys3Kd4sNJc7X8LVMRP89GKbOzlOGp03tGYj+mY4Kic.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '[localhost]:60029' (ECDSA) to the list of known hosts.
root@localhost's password:
  _____
  /  _  \ __________ _________   ____
 /  /_\  \___   /  |  \_  __ \_/ __ \
/    |    \/    /|  |  /|  | \/\  ___/
\____|__  /_____ \____/ |__|    \___  >
        \/      \/                  \/
A P P   S E R V I C E   O N   L I N U X

Documentation: http://aka.ms/webapp-linux
c315a18b39d2:/home#

#========= open a vi window to edit startup.sh ============
c315a18b39d2:/home# vi startup.sh

# ======== vi window =====================
#!/usr/bin/env bash^M
/opt/jboss/wildfly/bin/jboss-cli.sh -c --file=/home/site/deployments/tools/postgresql-datasource-commands.cli^M
~

remove those '^M' end of line characters and save the file

Step 3 - Copy the JMS Provider artefacts to the Wildfly configuration under generic JMS Provider

Where the files need to be copied through JBOSS CLI
```jboss-cli
cp  /home/site/deployments/tools/*.jar /opt/jboss/wildfly/modules/system/layers/base/org/jboss/genericjms/provider/main/
cp /home/site/deployments/tools/module.xml /opt/jboss/wildfly/modules/system/layers/base/org/jboss/genericjms/provider/main/
cp /home/site/deployments/tools/jndi.properties /opt/jboss/wildfly/standalone/configuration/
```

Step 4 - Add Subsystem to Wildfly configuration for the Remote connectionfactory and queue

Where the commands need to be executed through JBOSS CLI

```jboss-cli
/subsystem=ee:list-add(name=global-modules, value={"name" => "org.jboss.genericjms.provider", "slot" =>"main"}
/subsystem=naming/binding="java:global/remoteJMS":add(binding-type=external-context,module=org.jboss.genericjms.provider,class=javax.naming.InitialContext,environment=[java.naming.factory.initial=org.apache.qpid.jms.jndi.JmsInitialContextFactory,org.jboss.as.naming.lookup.by.string=true,java.naming.provider.url=/home/site/deployments/tools/jndi.properties])
/subsystem=resource-adapters/resource-adapter=generic-ra:add(module=org.jboss.genericjms,transaction-support=XATransaction)
/subsystem=resource-adapters/resource-adapter=generic-ra/connection-definitions=sbf-cd:add(class-name=org.jboss.resource.adapter.jms.JmsManagedConnectionFactory, jndi-name=java:/jms/SBF)
/subsystem=resource-adapters/resource-adapter=generic-ra/connection-definitions=sbf-cd/config-properties=ConnectionFactory:add(value=SBF)
/subsystem=resource-adapters/resource-adapter=generic-ra/connection-definitions=sbf-cd/config-properties=JndiParameters:add(value="java.naming.factory.initial=org.apache.qpid.jms.jndi.JmsInitialContextFactory;java.naming.provider.url=/home/site/deployments/tools/jndi.properties")
/subsystem=resource-adapters/resource-adapter=generic-ra/connection-definitions=sbf-cd:write-attribute(name=security-application,value=true)
/subsystem=ejb3:write-attribute(name=default-resource-adapter-name, value=generic-ra)
reload --use-current-server-config=true
```

##### Step 2: redeploy (OR) Restart the webapp

```bash
mvn azure-webapp:deploy
```


