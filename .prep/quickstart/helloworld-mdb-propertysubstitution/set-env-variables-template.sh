#!/usr/bin/env bash

# Azure Environment

export RESOURCEGROUP_NAME=<my resource group>
export WEBAPP_NAME=<my-webapp-name>
export WEBAPP_PLAN_NAME=${WEBAPP_NAME}-appservice-plan
export REGION=westus

# Supply these secrets for Service Bus
## Service Bus secrets
export DEFAULT_SBNAMESPACE=<my Servicebus namespace>
export SB_SAS_POLICY=<my Servicebus Send PolicyName>
export SB_SAS_KEY=<my Servicebus Primary/SecondaryAccessKey>
export SB_QUEUE=<my Servicebus queuename>
export SB_TOPIC=<my Servicebus topicname>
export SB_SUBSCRIPTION=<my Servicebus topic subscriptionname>
export PROP_HELLOWORLDMDB_CONN=<lookup value for MDB connectionfactory prop>
export PROP_HELLOWORLDMDB_QUEUE=<lookup value for MDB queue prop>
export PROP_HELLOWORLDMDB_TOPIC=<lookup value for MDB topic prop>
export PROP_HELLOWOROLDMDB_SUBSCRIPTION=<lookup value for MDB topic subscription prop>
## Compose secrets
export PROVIDER_URL=amqps://${DEFAULT_SBNAMESPACE}.servicebus.windows.net?amqp.idleTimeout=120000
