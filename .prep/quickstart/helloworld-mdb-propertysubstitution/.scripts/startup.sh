echo "Generating jndi.properties file in /home/site/deployments/tools directory"
echo "connectionfactory.${PROP_HELLOWORLDMDB_CONN}=amqps://${DEFAULT_SBNAMESPACE}.servicebus.windows.net?amqp.idleTimeout=120000&jms.username=${SB_SAS_POLICY}&jms.password=${SB_SAS_KEY}" > /home/site/deployments/tools/jndi.properties
echo "queue.${PROP_HELLOWORLDMDB_QUEUE}=${SB_QUEUE}" >> /home/site/deployments/tools/jndi.properties
echo "topic.${PROP_HELLOWORLDMDB_TOPIC}=${SB_TOPIC}" >> /home/site/deployments/tools/jndi.properties
echo "queue.${PROP_HELLOWOROLDMDB_SUBSCRIPTION}=${SB_TOPIC}/Subscriptions/${SB_SUBSCRIPTION}" >> /home/site/deployments/tools/jndi.properties
echo "====== contents of /home/site/deployments/tools/jndi.properties ======"
cat /home/site/deployments/tools/jndi.properties
echo "====== EOF /home/site/deployments/tools/jndi.properties ======"
echo "Generating commands.cli file for /home/site/deployments/tools directory"
echo "# Start batching commands" > /home/site/deployments/tools/commands.cli
echo "batch" >> /home/site/deployments/tools/commands.cli
echo "# Configure the ee subsystem to enable MDB annotation property substitution" >> /home/site/deployments/tools/commands.cli
echo "/subsystem=ee:write-attribute(name=annotation-property-replacement,value=true)" >> /home/site/deployments/tools/commands.cli
echo "# Define system properties to be used in the substititution" >> /home/site/deployments/tools/commands.cli
echo "/system-property=property.helloworldmdb.queue:add(value=java:global/remoteJMS/${PROP_HELLOWORLDMDB_QUEUE})" >> /home/site/deployments/tools/commands.cli
echo "/system-property=property.helloworldmdb.topic:add(value=java:global/remoteJMS/${PROP_HELLOWOROLDMDB_SUBSCRIPTION})" >> /home/site/deployments/tools/commands.cli
echo "/system-property=property.connection.factory:add(value=java:global/remoteJMS/${PROP_HELLOWORLDMDB_CONN})" >> /home/site/deployments/tools/commands.cli
echo "/subsystem=ee:list-add(name=global-modules, value={\"name\" => \"org.jboss.genericjms.provider\", \"slot\" =>\"main\"}" >> /home/site/deployments/tools/commands.cli
echo "/subsystem=naming/binding=\"java:global/remoteJMS\":add(binding-type=external-context,module=org.jboss.genericjms.provider,class=javax.naming.InitialContext,environment=[java.naming.factory.initial=org.apache.qpid.jms.jndi.JmsInitialContextFactory,org.jboss.as.naming.lookup.by.string=true,java.naming.provider.url=/home/site/deployments/tools/jndi.properties])" >> /home/site/deployments/tools/commands.cli
echo "/subsystem=resource-adapters/resource-adapter=generic-ra:add(module=org.jboss.genericjms,transaction-support=XATransaction)" >> /home/site/deployments/tools/commands.cli
echo "/subsystem=resource-adapters/resource-adapter=generic-ra/connection-definitions=sbf-cd:add(class-name=org.jboss.resource.adapter.jms.JmsManagedConnectionFactory, jndi-name=java:/jms/${PROP_HELLOWORLDMDB_CONN})" >> /home/site/deployments/tools/commands.cli
echo "/subsystem=resource-adapters/resource-adapter=generic-ra/connection-definitions=sbf-cd/config-properties=ConnectionFactory:add(value=${PROP_HELLOWORLDMDB_CONN})" >> /home/site/deployments/tools/commands.cli
echo "/subsystem=resource-adapters/resource-adapter=generic-ra/connection-definitions=sbf-cd/config-properties=JndiParameters:add(value=\"java.naming.factory.initial=org.apache.qpid.jms.jndi.JmsInitialContextFactory;java.naming.provider.url=/home/site/deployments/tools/jndi.properties\")" >> /home/site/deployments/tools/commands.cli
echo "/subsystem=resource-adapters/resource-adapter=generic-ra/connection-definitions=sbf-cd:write-attribute(name=security-application,value=true)" >> /home/site/deployments/tools/commands.cli
echo "/subsystem=ejb3:write-attribute(name=default-resource-adapter-name, value=generic-ra)" >> /home/site/deployments/tools/commands.cli
echo "# Run the batch commands" >> /home/site/deployments/tools/commands.cli
echo "run-batch" >> /home/site/deployments/tools/commands.cli
echo "reload" >> /home/site/deployments/tools/commands.cli
echo "====== contents of /home/site/deployments/tools/commands.cli ======"
cat /home/site/deployments/tools/commands.cli
echo "======= EOF /home/site/deployments/tools/commands.cli ========"
mkdir /opt/jboss/wildfly/modules/system/layers/base/org/jboss/genericjms/provider
mkdir /opt/jboss/wildfly/modules/system/layers/base/org/jboss/genericjms/provider/main
cp  /home/site/deployments/tools/*.jar /opt/jboss/wildfly/modules/system/layers/base/org/jboss/genericjms/provider/main/
cp /home/site/deployments/tools/module.xml /opt/jboss/wildfly/modules/system/layers/base/org/jboss/genericjms/provider/main/
cp /home/site/deployments/tools/jndi.properties /opt/jboss/wildfly/standalone/configuration/
/opt/jboss/wildfly/bin/jboss-cli.sh -c --file=/home/site/deployments/tools/commands.cli
echo "Startup Run done"
