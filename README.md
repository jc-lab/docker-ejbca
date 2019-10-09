# Example

```bash
$ sudo docker run \
  -e CA_NAME="Your CA" -e CA_DN="CN=Management CA,O=YourCompany,C=KR" \
  -e CA_KEYSPEC=4096 -e CA_KEYTYPE="rsa" -e CA_SIGNALG="SHA512WithRSA" -e CA_VALIDITY="10950" \
  -e DB_USER=ejbca -e DB_PASSWORD="abcdefg" -e DB_URL="jdbc:mysql://localhost/ejbca?characterEncoding=UTF-8" \
  -e DB_DRIVER="org.mariadb.jdbc.Driver" -e DB_NAME="mysql" \
  -e WEB_HTTP_HOSTNAME="ca-pki.YourCompany.com" -e WEB_HTTP_DN="CN=ca-pki.YourCompany.com,OU=Your CA,O=YourCompany,C=KR" \
  --privileged -v /dev/bus/usb/:/dev/bus/usb/ --net=host --name ejbca -it ejbca
```
