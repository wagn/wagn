FROM jpetazzo/pgsql
MAINTAINER Gerry Gleason (ggleason@tribpub.com)

ADD init /init
# /init will run this and remove it when initializing
ADD template_uuen.sql /tmp/script/

ENTRYPOINT ["/init"]
CMD ["a_password"]
