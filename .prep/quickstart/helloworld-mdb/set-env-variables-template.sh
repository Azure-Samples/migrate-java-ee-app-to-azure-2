#!/usr/bin/env bash

# Azure Environment

export RESOURCEGROUP_NAME=<my resource group>
export WEBAPP_NAME=<my-webapp-name>
export WEBAPP_PLAN_NAME=${WEBAPP_NAME}-appservice-plan
export REGION=westus

# Supply these secrets for Service Bus
export DEFAULT_CONNECTION_FACTORY=<ConnectionFactory Key>
export DEFAULT_DESTINATION=<Quey Key>
export INITIAL_CONTEXT_FACTORY=org.apache.qpid.jms.jndi.JmsInitialContextFactory
export DEFAULT_SBNAMESPACE=<my Servicebus namespace>
export DEFAULT_USERNAME=<my Servicebus Send PolicyName>
export DEFAULT_PASSWORD=<my Servicebus AccessKey>
export DESTINATION_QUEUE=<my Servicebus queuename>

## Secrets composed from supplied secrets for Service Bus
export PROVIDER_URL=amqps://${DEFAULT_SBNAMESPACE}.servicebus.windows.net?amqp.idleTimeout=120000

# FTP Secrets
# Use Azure CLI to get them
# az webapp deployment list-publishing-profiles -g ${RESOURCEGROUP_NAME} -n ${WEBAPP_NAME}

#export FTP_HOST=<my ftp host>
#export FTP_USERNAME=<my ftp user name>
#export FTP_PASSWORD=<my ftp password>

