FROM alpine:3.15

MAINTAINER R0NAM1 mcevan9@gmail.com

#Install postfix
RUN apk update && \
    apk add supervisor postfix && apk add bash nmap-ncat postfix-ldap libsasl

#Install Dovecot
RUN apk add \
  dovecot \
  dovecot-gssapi \
  dovecot-ldap \
  dovecot-lmtpd \
#  dovecot-sql \
  dovecot-pigeonhole-plugin \
  dovecot-pop3d \
#  dovecot-submissiond \
  ca-certificates && rm -rf /var/cache/apk/*

COPY ./supervisord.conf /etc/supervisor/supervisord.conf

#RUN addgroup dovecot mail

CMD /usr/bin/supervisord -c /etc/supervisor/supervisord.conf

HEALTHCHECK CMD ncat -C 127.0.0.1 25 || exit 1

SHELL ["/bin/bash", "-c"]

EXPOSE 25
