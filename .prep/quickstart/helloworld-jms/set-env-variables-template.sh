#!/usr/bin/env bash
## Connection String details for Initial Context
export DEFAULT_CONNECTION_FACTORY=<ConnectionFactory Key>
export DEFAULT_DESTINATION=<Quey Key>
export INITIAL_CONTEXT_FACTORY=org.apache.qpid.jms.jndi.JmsInitialContextFactory
export DEFAULT_MESSAGE_COUNT=1

## Service Bus secrets
export DEFAULT_SBNAMESPACE=<my Servicebus namespace>
export DEFAULT_USERNAME=<my Servicebus Send PolicyName>
export DEFAULT_PASSWORD=<my Servicebus AccessKey>
export DESTINATION_QUEUE=<my Servicebus queuename>

## Compose secrets
export PROVIDER_URL=amqps://${DEFAULT_SBNAMESPACE}.servicebus.windows.net?amqp.idleTimeout=120000