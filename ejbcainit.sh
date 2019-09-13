#!/bin/bash
# set properties files
echo "#------- settings ejbca.properties --------" > $EJBCA_HOME/conf/ejbca.properties
echo "#jboss.config=all" >> $EJBCA_HOME/conf/ejbca.properties
echo "#jboss.farm.name=farm" >> $EJBCA_HOME/conf/ejbca.properties
echo "appserver.home=$JBOSS_HOME" >> $EJBCA_HOME/conf/ejbca.properties
echo "appserver.type=jboss" >> $EJBCA_HOME/conf/ejbca.properties
echo "ejbca.cli.defaultusername=$EJBCA_CLI_USER" >> $EJBCA_HOME/conf/ejbca.properties
echo "ejbca.cli.defaultpassword=$EJBCA_CLI_PASSWORD" >> $EJBCA_HOME/conf/ejbca.properties
echo "ejbca.passwordlogrounds=8" >> $EJBCA_HOME/conf/ejbca.properties

echo "#------- settings cesecore.properties --------" > $EJBCA_HOME/conf/cesecore.properties
echo "ca.keystorepass=$EJBCA_KS_PASS" >> $EJBCA_HOME/conf/cesecore.properties

echo "#------- settings install.properties --------" > $EJBCA_HOME/conf/install.properties
echo "ca.name=$CA_NAME" >> $EJBCA_HOME/conf/install.properties
echo "ca.dn=$CA_DN" >> $EJBCA_HOME/conf/install.properties
if [[ "$CA_TOKENTYPE" != "" ]]; then
	echo "ca.tokentype=$CA_TOKENTYPE" >> $EJBCA_HOME/conf/install.properties
	if [[ "$_CA_TOKENTYPE" != "soft" ]]; then
		echo "ca.tokenpassword=$CA_TOKENPASSWORD" >> $EJBCA_HOME/conf/install.properties	
		echo "ca.tokenproperties=/opt/catoken.properties" >> $EJBCA_HOME/conf/install.properties
	else
		echo "ca.tokenpassword=null" >> $EJBCA_HOME/conf/install.properties
	fi
else
	echo "ca.tokentype=soft" >> $EJBCA_HOME/conf/install.properties
	echo "ca.tokenpassword=null" >> $EJBCA_HOME/conf/install.properties
fi
echo "ca.keyspec=$CA_KEYSPEC" >> $EJBCA_HOME/conf/install.properties
echo "ca.keytype=$CA_KEYTYPE" >> $EJBCA_HOME/conf/install.properties
echo "ca.signaturealgorithm=$CA_SIGNALG" >> $EJBCA_HOME/conf/install.properties
echo "ca.validity=$CA_VALIDITY" >> $EJBCA_HOME/conf/install.properties
echo "ca.policy=null" >> $EJBCA_HOME/conf/install.properties

if [[ "$CA_SLOT_LABEL_TYPE" != "" ]]; then
	if [[ "$CA_PKCS11_LIBRARY" ]]; then
		echo "sharedLibrary=$CA_PKCS11_LIBRARY" > /opt/catoken.properties
	else
	       	echo "sharedLibrary=/usr/lib64/opensc-pkcs11.so" > /opt/catoken.properties
	fi
	echo "slotLabelType=$CA_SLOT_LABEL_TYPE" >> /opt/catoken.properties
	echo "slotLabelValue=$CA_SLOT_LABEL_VALUE" >> /opt/catoken.properties
	echo "pin=$CA_SLOT_PIN" >> /opt/catoken.properties
	echo "certSignKey=$CA_SLOT_SIGNKEY" >> /opt/catoken.properties
	echo "crlSignKey=$CA_SLOT_SIGNKEY" >> /opt/catoken.properties
	echo "defaultKey=$CA_SLOT_SIGNKEY" >> /opt/catoken.properties
fi

echo "#------- settings web.properties --------" > $EJBCA_HOME/conf/web.properties
echo "superadmin.cn=$WEB_SUPERADMIN" >> $EJBCA_HOME/conf/web.properties
echo "superadmin.dn=CN=\${superadmin.cn}" >> $EJBCA_HOME/conf/web.properties
echo "superadmin.password=ejbca" >> $EJBCA_HOME/conf/web.properties
echo "java.trustpassword=$WEB_JAVA_TRUSTPASSWORD" >> $EJBCA_HOME/conf/web.properties
echo "superadmin.batch=true" >> $EJBCA_HOME/conf/web.properties
echo "httpsserver.password=$WEB_HTTP_PASSWORD" >> $EJBCA_HOME/conf/web.properties
echo "httpsserver.hostname=$WEB_HTTP_HOSTNAME" >> $EJBCA_HOME/conf/web.properties
echo "httpsserver.dn=$WEB_HTTP_DN" >> $EJBCA_HOME/conf/web.properties
echo "web.selfreg.enabled=$WEB_SELFREG" >> $EJBCA_HOME/conf/web.properties
echo "httpserver.pubhttp=8080" >> $EJBCA_HOME/conf/web.properties
echo "httpserver.pubhttps=8442" >> $EJBCA_HOME/conf/web.properties
echo "httpserver.privhttps=8443" >> $EJBCA_HOME/conf/web.properties
echo "httpserver.external.privhttps=443" >> $EJBCA_HOME/conf/web.properties

echo "cryptotoken.p11.lib.60.name=SmartCard-HSM" >> $EJBCA_HOME/conf/web.properties
echo "cryptotoken.p11.lib.60.file=/usr/lib64/opensc-pkcs11.so" >> $EJBCA_HOME/conf/web.properties
echo "cryptotoken.p11.defaultslot=1" >> $EJBCA_HOME/conf/web.properties

# deploy and install ear
cd $EJBCA_HOME
# deploy
ant build deploy
rc=$?
if [[ $rc -ne 0 ]] ; then
  echo "Error while executing ant deploy, rc=$rc"; exit $rc
fi
# install
ant install
rc=$?
if [[ $rc -ne 0 ]] ; then
  echo "Error while executing ant install, rc=$rc"; exit $rc
fi

# copy key to root fs for easy copy
cp $EJBCA_HOME/p12/superadmin.p12 /superadmin.p12

