#!/bin/bash

# docker exec exchange_server rm -rf /usr/bin/python
# docker exec exchange-client rm -rf /usr/bin/python
# docker exec tld-server rm -rf /usr/bin/python
# docker exec tld-spider rm -rf /usr/bin/python
# docker exec tld-collector rm -rf /usr/bin/python
# docker exec zone-collector rm -rf /usr/bin/python

# docker exec exchange_server ln -s /opt/Share/python27/bin/python2.7 /usr/bin/python
# docker exec exchange-client ln -s /opt/Share/python27/bin/python2.7 /usr/bin/python
# docker exec tld-server ln -s /opt/Share/python27/bin/python2.7 /usr/bin/python
# docker exec tld-spider ln -s /opt/Share/python27/bin/python2.7 /usr/bin/python
# docker exec tld-collector ln -s /opt/Share/python27/bin/python2.7 /usr/bin/python
# docker exec zone-collector ln -s /opt/Share/python27/bin/python2.7 /usr/bin/python

# docker exec root-spider killall nrpe
# docker exec exchange_server killall nrpe
# docker exec exchange-client killall nrpe
# docker exec tld-server killall nrpe
# docker exec tld-spider killall nrpe
# docker exec tld-collector killall nrpe
# docker exec zone-collector killall nrpe
# docker exec wiki killall nrpe
docker exec peer-resolution killall nrpe
docker exec emergency-response-interface killall nrpe

# docker exec root-spider /opt/Share/nrpe/bin/nrpe -d -c /opt/Share/nrpe/etc/nrpe.cfg
# docker exec exchange_server /opt/Share/nrpe/bin/nrpe -d -c /opt/Share/nrpe/etc/nrpe.cfg
# docker exec exchange-client /opt/Share/nrpe/bin/nrpe -d -c /opt/Share/nrpe/etc/nrpe.cfg
# docker exec tld-server /opt/Share/nrpe/bin/nrpe -d -c /opt/Share/nrpe/etc/nrpe.cfg
# docker exec tld-spider /opt/Share/nrpe/bin/nrpe -d -c /opt/Share/nrpe/etc/nrpe.cfg
# docker exec tld-collector /opt/Share/nrpe/bin/nrpe -d -c /opt/Share/nrpe/etc/nrpe.cfg
# docker exec zone-collector /opt/Share/nrpe/bin/nrpe -d -c /opt/Share/nrpe/etc/nrpe.cfg
# docker exec wiki /opt/Share/nrpe/bin/nrpe -d -c /opt/Share/nrpe/etc/nrpe.cfg
docker exec peer-resolution /opt/Share/nrpe/bin/nrpe -d -c /opt/Share/nrpe/etc/nrpe.cfg
docker exec emergency-response-interface /opt/Share/nrpe/bin/nrpe -d -c /opt/Share/nrpe/etc/nrpe.cfg
