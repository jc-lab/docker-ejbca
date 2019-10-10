#!/bin/sh

if [ ! -f /opt/.installed ]; then
  cp -rf /opt.init/* /opt/
  touch /opt/.installed
fi

pcscd
/opt/init.sh

