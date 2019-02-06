mkdir /opt/jboss/wildfly/modules/system/layers/base/org/jboss/genericjms/provider
mkdir /opt/jboss/wildfly/modules/system/layers/base/org/jboss/genericjms/provider/main
cp  /home/site/deployments/tools/*.jar /opt/jboss/wildfly/modules/system/layers/base/org/jboss/genericjms/provider/main/
cp /home/site/deployments/tools/module.xml /opt/jboss/wildfly/modules/system/layers/base/org/jboss/genericjms/provider/main/
cp /home/site/deployments/tools/jndi.properties /opt/jboss/wildfly/standalone/configuration/
/opt/jboss/wildfly/bin/jboss-cli.sh -c --file=/home/site/deployments/tools/commands.cli
