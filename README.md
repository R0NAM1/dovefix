Dovefix is a combination Docker image of Postfix and Dovecot that fully exposes the config files (And has LDAP examples),
making it lightweight, easy to manage and is as configurable as is needed!

How to install:
1. Git clone into your own directory

2. Generate needed SSL TLS files for secure connections between servers

3. Create directory for holding Certificates and use either command depending or import custom certs, fullchain.pem and privkey.pem are needed
(Good example is just ./certificates)

=====
(Cloudflare examples)

Create new cert:
sudo docker run -it --rm --name certbot -v "./CertificateLocation/:/etc/letsencrypt/" -v "/CloudflareINI/cloudflare.ini:/cloudflare.ini:ro" --dns 1.1.1.1 certbot/dns-cloudflare certonly --dns-cloudflare --dns-cloudflare-credentials /cloudflare.ini -m your@e.mail --agree-tos --no-eff-email --dns-cloudflare-propagation-seconds 20 --cert-name '*.domain' -d *.domain

Renew Cert:
sudo docker run -it --rm --name certbot -v "./CertificateLocation:/etc/letsencrypt/" -v "/CloudflareINI/cloudflare.ini:/cloudflare.ini:ro" --dns 1.1.1.1 certbot/dns-cloudflare renew --cert-name '*.domain' -v

cloudflare.ini:
# Cloudflare API token used by Certbot
dns_cloudflare_api_token = specialTokenThatCanManageDNS
=====

4. Once certificates are aquired, set as needed in dovecot.conf where ssl_cert and ssl_key paramater is and in main.cf at #STARTTLS

5. dovecot.conf should be fine as is now, need to edit database, which in this case is ldap at dovecot-ldap.conf.ext

6. Set needed paramaters in main.cf and master.cf, and dovecot conf.d files

7. In docker, generate a new external network with the name dovefix-network, using any subnet (Like 172.28.0.0/16). Set static addresses for each container. In main.cf set mynetworks to include any networks allowed to contact SMTP plus the newly added network

(docker network create --driver=bridge --subnet=172.28.0.0/16 dovefix-network)

8. Also in main.cf, set smtpd_milters and non_ to smtpd_milters = inet:(Rspamd address):11332

9. Time to generate dkim keys as last step before running email!

10. Command is 'sudo opendkim-genkey -b 1024 -d my.domain -D ./rspamd/dkimKeys/ -s default -v'

11. rSpamd only SIGNS mail with dkim, does not generate keys. To tell rSpamd to sign mail we need to use the dkim_signing.conf.example and place that in ./rspamd/override.d/ as that is the priority directory for rspamd configuration, do that with other config

12. Replace any instances of my.domain with your domain

13. Create docker container through running docker build . -t r0nam1/dovefix:latest

Time to edit configs, one program at a time to suit your needs

14. Time to run containers through docker-compose up -d!

15. rSpamd will not allow you to log in until you 'docker exec -it rspamd rspamadm pw' to generate a hashed password to go into worker-controller.inc


