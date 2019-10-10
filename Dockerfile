# written by Benoit Sarda
# ejbca container. uses bsarda/jboss by copy/paste.
#
#   bsarda <b.sarda@free.fr>
#
FROM bsarda/ejbca
MAINTAINER Jichan <development@jc-lab.net>

EXPOSE 8080 8442 8443

ARG LIBP11_VERSION=0.4.10
ARG OPENSC_VERSION=0.20.0
ARG OPENSC_VERSION_TAG=0.20.0-rc2

RUN mkdir -p /usr/src/build
WORKDIR /usr/src/build
RUN yum clean all && rpm --rebuilddb; yum install -y yum-plugin-ovl && yum install -y opensc gcc openssl ccid autoconf automake curl gettext openssl-devel m4 libtool readline-devel zlib-devel pcsc-lite-devel pcsc-lite && yum clean all
RUN curl -fsL https://github.com/OpenSC/OpenSC/releases/download/${OPENSC_VERSION_TAG}/opensc-${OPENSC_VERSION}.tar.gz  -o opensc-${OPENSC_VERSION}.tar.gz \
    && tar -zxf opensc-${OPENSC_VERSION}.tar.gz \
    && rm opensc-${OPENSC_VERSION}.tar.gz \
    && cd opensc-${OPENSC_VERSION} \
    && ./bootstrap \
    && ./configure \
        --host=x86_64-alpine-linux-musl \
        --prefix=/usr \
        --libdir=/usr/lib64 \ 
        --sysconfdir=/etc \
        --disable-man \
        --enable-zlib \
        --enable-readline \
        --enable-openssl \
        --enable-pcsc \
        --enable-sm \
        CC='gcc' \
    && make \
    && make install \
    && curl -fsL https://github.com/OpenSC/libp11/releases/download/libp11-${LIBP11_VERSION}/libp11-${LIBP11_VERSION}.tar.gz -o libp11-${LIBP11_VERSION}.tar.gz \
    && tar -zxf libp11-${LIBP11_VERSION}.tar.gz \
    && rm libp11-${LIBP11_VERSION}.tar.gz \
    && cd libp11-${LIBP11_VERSION} \
    && ./configure --prefix=/usr --libdir=/usr/lib64 \
    && make \
    && make install \
    && rm -r /usr/src/build \
    && yum remove -y make autoconf automake gcc

RUN groupadd -r -g 901 opensc \
    && useradd -r -u 901 -g opensc -s /bin/sh -d /run/pcscd opensc \
    && mkdir -p /run/pcscd \
    && chown -R nobody:nobody /run/pcscd

RUN yum install -y which

COPY "jboss-modules-1.1.5.ga.jar" "/opt/jboss-as-7.1.1.Final/"

RUN  rm /opt/jboss-as-7.1.1.Final/jboss-modules.jar \
  && mv /opt/jboss-as-7.1.1.Final/jboss-modules-1.1.5.ga.jar /opt/jboss-as-7.1.1.Final/jboss-modules.jar \
  && sed -r -e 's/^#(security\.provider\.[0-9]+=sun\.security\.pkcs11)/\1/g' -i $(dirname $(readlink -f $(which java)))/../lib/security/java.security

RUN sed -e 's/<\/paths>/<path name="sun\/security\/x509"\/>\n<path name="sun\/security\/pkcs11"\/>\n<path name="sun\/security\/pkcs11\/wrapper"\/>\n<\/paths>/g' -i /opt/jboss-as-*/modules/sun/jdk/main/module.xml

RUN rm -f /opt/ejbcainit.sh
ADD "ejbcainit.sh" "/opt/ejbcainit.sh"

WORKDIR "/"
ADD "docker-entrypoint.sh" "/docker-entrypoint.sh"

CMD ["/docker-entrypoint.sh"]

