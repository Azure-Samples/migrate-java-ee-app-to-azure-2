---
services: app-service
platforms: java
author: selvasingh, sadigopu
---

# Migrate Java Console App with JMS API
This guide walks you through the process of migrating an 
existing Java EE workload to Azure, aka:
 
- Websockets-based chat application

## Table of Contents
 * [Migrate Java Messaging to to Azure](#migrate-java-ee-app-to-azure)
      * [What you will migrate to cloud](#what-you-will-migrate-to-cloud)
      * [What you will need](#what-you-will-need)
      * [Getting Started](#getting-started)
         * [Step ONE - Clone and Prep](#step-one---clone-and-prep)
      * [Create Azure Servicebus](#)
        * [Add MySQL Profile](#add-mysql-profile)
## What you will migrate to cloud

You will migrate the Wildfly Quickstart JMS API console application as 
sample app to demonstrate the enterprise scenario of sending & receiving messages
from a queue :

- Java EE 7
- Sockets

Upon migration, you will power the app using 
Azure Linux AppService with websocket ON

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

cd quickstart/websocket-hello
$ mvn package -Dmaven.test.skip=true
```

### Create AppService in Azure using Azure CLI
Login to Azure by using the 'az login' command and follow the instructions that give a device code to be entered in browser

```bash
az login
```
Set environment variables for binding secrets at runtime, 
particularly Azure resource group details. You can 
export them to your local environment, say using the supplied
Bash shell script template.

```bash
mkdir .scripts
cp set-env-variables-template.sh .scripts/set-env-variables.sh

#Modify the environment variables in set-env-variables.sh
vi .scripts/set-env-variables.sh
. .scripts/set-env-variables.sh                                         
```

mvn package -Dmaven.test.skip=true

### Deploy to Azure - Create the Webapp

Add [Maven Plugin for Azure App Service](https://github.com/Microsoft/azure-maven-plugins/blob/develop/azure-webapp-maven-plugin/README.md) configuration to POM.xml and deploy
Chat application to WildFly in App Service Linux:

``` xml
### Deploy Webapp to Azure
### Add in plugins
<build>
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
</plugins>
</build>
```
mvn azure-webapp:deploy