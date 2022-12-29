FROM debian:bullseye-slim AS pre_bulder

RUN apt-get update && apt-get --assume-yes install wget gnupg ssh

RUN echo "deb http://apt.postgresql.org/pub/repos/apt bullseye-pgdg main 15" > /etc/apt/sources.list.d/pgdg.list
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

RUN apt-get update && apt-get --assume-yes  --no-install-recommends  install postgresql-15 postgresql-15-pgaudit postgresql-15-pglogical postgresql-15-wal2json postgresql-15-pgpool2 patroni pgbackrest

###
# I want data checksum in new cluster; destroying the one apt created
RUN rm -rf /var/lib/postgresql/ &&  mkdir -p /var/lib/postgresql/ && chown -R postgres: /var/lib/postgresql/

RUN su postgres -c "/usr/lib/postgresql/15/bin/initdb -D /var/lib/postgresql/15/main --auth-local peer --auth-host scram-sha-256 --no-instructions --data-checksums "

###
# Cleanup
RUN rm -r /usr/share/doc/* && \
    rm -r /usr/share/man/* && \
    rm -r /usr/share/locale/* && \
    rm /var/log/*.log /var/log/lastlog /var/log/wtmp /var/log/apt/*.log /var/log/apt/*.xz


####

FROM pre_bulder as build_primary

COPY ./myEntrypoint.sh /docker-entrypoint-initdb.d/
RUN chmod +x /docker-entrypoint-initdb.d/*sh

COPY ./postgresql.conf.primary   /etc/postgresql/15/main/
COPY ./postgresql.conf.secondary /etc/postgresql/15/main/
COPY ./pg_hba.conf               /etc/postgresql/15/main/

ENTRYPOINT /docker-entrypoint-initdb.d/myEntrypoint.sh; while true; do sleep 999; done;
