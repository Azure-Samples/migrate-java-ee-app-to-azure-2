echo "Generating jndi.properties file in /home/site/deployments/tools directory"
echo "connectionfactory.SBF=amqps://${DEFAULT_SBNAMESPACE}.servicebus.windows.net?amqp.idleTimeout=120000&jms.username=${SB_SAS_POLICY}&jms.password=${SB_SAS_KEY}" > /home/site/deployments/tools/jndi.properties
echo "queue.jmstestqueue=${SB_QUEUE}" >> /home/site/deployments/tools/jndi.properties
echo "====== contents of /home/site/deployments/tools/jndi.properties ======"
cat /home/site/deployments/tools/jndi.properties
echo "====== EOF /home/site/deployments/tools/jndi.properties ======"
mkdir /opt/jboss/wildfly/modules/system/layers/base/org/jboss/genericjms/provider
mkdir /opt/jboss/wildfly/modules/system/layers/base/org/jboss/genericjms/provider/main
cp  /home/site/deployments/tools/*.jar /opt/jboss/wildfly/modules/system/layers/base/org/jboss/genericjms/provider/main/
cp /home/site/deployments/tools/module.xml /opt/jboss/wildfly/modules/system/layers/base/org/jboss/genericjms/provider/main/
cp /home/site/deployments/tools/jndi.properties /opt/jboss/wildfly/standalone/configuration/
/opt/jboss/wildfly/bin/jboss-cli.sh -c --file=/home/site/deployments/tools/commands.cli
