---
services: service bus
platforms: java
author: selvasingh, sadigopu
---

# Migrate Java Console App with JMS API
This guide walks you through the process of migrating an 
existing Java EE workload to Azure, aka:
 
- Java Console App using JMS API 
- App's messaging queue moved to Azure Service Bus 

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
- JMS API

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

cd quickstart/helloworld-jms
$ mvn package -Dmaven.test.skip=true
[INFO] Scanning for projects...
[INFO]
[INFO] ---------------< org.wildfly.quickstarts:helloworld-jms >---------------
[INFO] Building Quickstart: helloworld-jms 14.0.1.Final
[INFO] --------------------------------[ jar ]---------------------------------
[INFO]
[INFO] --- maven-enforcer-plugin:3.0.0-M2:enforce (enforce-java-version) @ helloworld-jms ---
[INFO]
[INFO] --- maven-enforcer-plugin:3.0.0-M2:enforce (enforce-maven-version) @ helloworld-jms ---
[INFO]
[INFO] --- buildnumber-maven-plugin:1.4:create (get-scm-revision) @ helloworld-jms ---
[INFO] Executing: /bin/sh -c cd '/home/demouser/readyworkshop/migrate-java-ee-app-to-azure-2/quickstart/helloworld-jms' && 'git' 'rev-parse' '--verify' 'HEAD'
[INFO] Working directory: /home/demouser/readyworkshop/migrate-java-ee-app-to-azure-2/quickstart/helloworld-jms
[INFO] Storing buildNumber: 85353e73beca05c91f29ff27b761081f2da0b8d3 at timestamp: 1549267868998
[WARNING] Cannot get the branch information from the git repository:
Detecting the current branch failed: fatal: ref HEAD is not a symbolic ref

[INFO] Executing: /bin/sh -c cd '/home/demouser/readyworkshop/migrate-java-ee-app-to-azure-2/quickstart/helloworld-jms' && 'git' 'rev-parse' '--verify' 'HEAD'
[INFO] Working directory: /home/demouser/readyworkshop/migrate-java-ee-app-to-azure-2/quickstart/helloworld-jms
[INFO] Storing buildScmBranch: UNKNOWN
[INFO]
[INFO] --- maven-resources-plugin:3.1.0:resources (default-resources) @ helloworld-jms ---
[INFO] Using 'UTF-8' encoding to copy filtered resources.
[INFO] Copying 1 resource
[INFO]
[INFO] --- maven-compiler-plugin:3.7.0:compile (default-compile) @ helloworld-jms ---
[INFO] Changes detected - recompiling the module!
[INFO] Compiling 1 source file to /home/demouser/readyworkshop/migrate-java-ee-app-to-azure-2/quickstart/helloworld-jms/target/classes
[INFO]
[INFO] --- maven-checkstyle-plugin:3.0.0:checkstyle (check-style) @ helloworld-jms ---
[INFO] Starting audit...
Audit done.
[INFO]
[INFO] --- maven-resources-plugin:3.1.0:testResources (default-testResources) @ helloworld-jms ---
[INFO] Not copying test resources
[INFO]
[INFO] --- maven-compiler-plugin:3.7.0:testCompile (default-testCompile) @ helloworld-jms ---
[INFO] Not compiling test sources
[INFO]
[INFO] --- maven-surefire-plugin:2.22.0:test (default-test) @ helloworld-jms ---
[INFO] Tests are skipped.
[INFO]
[INFO] --- maven-jar-plugin:3.1.0:jar (default-jar) @ helloworld-jms ---
[INFO] Building jar: /home/demouser/readyworkshop/migrate-java-ee-app-to-azure-2/quickstart/helloworld-jms/target/helloworld-jms.jar
[INFO]
[INFO] --- maven-source-plugin:3.0.1:jar-no-fork (attach-sources) @ helloworld-jms ---
[INFO] Building jar: /home/demouser/readyworkshop/migrate-java-ee-app-to-azure-2/quickstart/helloworld-jms/target/helloworld-jms-sources.jar
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time:  7.863 s
[INFO] Finished at: 2019-02-04T08:11:13Z
[INFO] ------------------------------------------------------------------------

```

### Create Service Bus in Azure using Azure CLI
Login to Azure by using the 'az login' command and follow the instructions that give a device code to be entered in browser

```bash
az login
```
Set environment variables for binding secrets at runtime, 
particularly Azure resource group and Service bus details. You can 
export them to your local environment, say using the supplied
Bash shell script template.

```bash
mkdir .scripts
cp set-env-variables-template.sh .scripts/set-env-variables.sh

#Modify the environment variables in set-env-variables.sh
. .scripts/set-env-variables.sh


az servicebus namespace create --name  ${DEFAULT_SBNAMESPACE} \
                               --resource-group ${RESOURCEGROUP_NAME}

az servicebus queue create --name ${DESTINATION_QUEUE} \
                           --namespace-name ${DEFAULT_SBNAMESPACE} \
                           --resource-group ${RESOURCEGROUP_NAME}

az servicebus queue authorization-rule create --name DEFAULT_USERNAME \
                                              --namespace-name ${DEFAULT_SBNAMESPACE} \
                                              --queue-name ${DESTINATION_QUEUE} \
                                              --resource-group ${RESOURCEGROUP_NAME} \
                                              --rights Listen Send

az servicebus queue authorization-rule keys list --name DEFAULT_USERNAME \
                                                 --namespace-name ${DEFAULT_SBNAMESPACE} \
                                                 --queue-name ${DESTINATION_QUEUE} \
                                                 --resource-group ${RESOURCEGROUP_NAME}
                                                
```

From the values displayed for the keys, grab the <b>primarykey</b> value. Open the .scripts/set-env-variables.sh file and set the primaryKey as value for variable DEFAULT_PASSWORD.

```bash
. .scripts/set-env-variables.sh
```

### Run the JMS API console app
mvn clean compile exec:java