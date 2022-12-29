#!/bin/bash
set -e

/etc/init.d/ssh start
echo "export PATH=/usr/lib/postgresql/15/bin/:$PATH" >> /var/lib/postgresql/.bashrc
chown postgres: /var/lib/postgresql/.bash*


WHAT_AM_I=${WHAT_AM_I:-primary}

if [[ $WHAT_AM_I == 'primary' ]]; then
  cp /etc/postgresql/15/main/postgresql.conf.primary     /etc/postgresql/15/main/postgresql.conf
else
  cp /etc/postgresql/15/main/postgresql.conf.secondary   /etc/postgresql/15/main/postgresql.conf
  rm -rf /var/lib/postgresql/15/main
  echo "Waiting for master to connect..."
  sleep 5
  until (su postgres -c "pg_basebackup -h ${NEW_PRIMARY} -D /var/lib/postgresql/15/main -U repl_user -vP -R -Xs")
  do
    echo "Waiting for master to connect..."
    sleep 5
  done
fi


/etc/init.d/postgresql restart
sleep 2


if [[ $WHAT_AM_I == 'primary' ]]; then
  su postgres -c "psql << EOSQL
    CREATE USER wiwwo LOGIN SUPERUSER ENCRYPTED PASSWORD 'wiwwo123';
    CREATE USER repl_user REPLICATION LOGIN ENCRYPTED PASSWORD 'repl_user123';
EOSQL
  "
fi
