FROM debian:bullseye-slim AS pre_bulder

RUN apt-get update && apt-get --assume-yes install wget gnupg ssh less vim
RUN echo "deb http://apt.postgresql.org/pub/repos/apt bullseye-pgdg main 15" > /etc/apt/sources.list.d/pgdg.list
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN apt-get update && apt-get --assume-yes  --no-install-recommends  install postgresql-15 postgresql-15-pgaudit postgresql-15-pglogical postgresql-15-wal2json postgresql-15-pgpool2 patroni pgbackrest


### ### ### ### ### ###
# I want data checksum in new cluster; destroying the one apt created
RUN rm -rf /var/lib/postgresql/ &&  mkdir -p /var/lib/postgresql/ && chown -R postgres: /var/lib/postgresql/
RUN su postgres -c "/usr/lib/postgresql/15/bin/initdb -D /var/lib/postgresql/15/main --auth-local peer --auth-host scram-sha-256 --no-instructions --data-checksums "


### ### ### ### ### ###
RUN mkdir -p /root/.ssh /var/lib/postgresql/.ssh
COPY ./id_rsa* /root/.ssh
COPY ./id_rsa* /var/lib/postgresql/.ssh
RUN cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys
RUN cat /root/.ssh/id_rsa.pub >> /var/lib/postgresql/.ssh/authorized_keys
RUN chmod 700 /var/lib/postgresql/.ssh; chmod 600 /var/lib/postgresql/.ssh/id_rsa*; chown -R postgres: /var/lib/postgresql/.ssh;
RUN chmod 700 /root/.ssh; chmod 600 /root/.ssh/id_rsa*;

COPY pgpass /root/.pgpass
COPY psqlrc /root/.psqlrc
COPY pgpass /var/lib/postgresql/.pgpass
COPY psqlrc /var/lib/postgresql/.psqlrc
RUN chmod 700 /root/.pgpass
RUN chmod 700 /var/lib/postgresql/.pgpass
RUN chown postgres: /var/lib/postgresql/.p*

COPY ./postgresql.conf.primary   /etc/postgresql/15/main/
COPY ./postgresql.conf.replica   /etc/postgresql/15/main/
COPY ./pg_hba.conf               /etc/postgresql/15/main/

COPY ./myEntrypoint.sh /docker-entrypoint-initdb.d/

RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    locale-gen \
    chsh -s /bin/bash \
RUN echo "root:root123" | chpasswd
RUN echo "postgres:postgres123" | chpasswd

### ### ### ### ### ###
# Cleanup
RUN rm -r /usr/share/doc/* && \
    rm -r /usr/share/man/* && \
    rm -r /usr/share/locale/* && \
    rm /var/log/*.log /var/log/lastlog /var/log/wtmp /var/log/apt/*.log /var/log/apt/*.xz
RUN echo -n > /etc/motd
