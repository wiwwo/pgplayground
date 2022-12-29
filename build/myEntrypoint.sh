#!/bin/bash
set -e

/etc/init.d/ssh start
echo "export PATH=/usr/lib/postgresql/15/bin/:$PATH" >> /var/lib/postgresql/.bashrc
cp /var/lib/postgresql/.bashrc /var/lib/postgresql/.bash_profile
chown postgres: /var/lib/postgresql/.bash*


WHAT_AM_I=${WHAT_AM_I:-primary}

if [[ $WHAT_AM_I == 'console' ]]; then
  # Automatically accept ssh fingerprint
  ssh-keyscan -H console  >> ~/.ssh/known_hosts
  ssh-keyscan -H pg_red   >> ~/.ssh/known_hosts
  ssh-keyscan -H pg_green >> ~/.ssh/known_hosts
  ssh-keyscan -H pg_blue  >> ~/.ssh/known_hosts
  cp ~/.ssh/known_hosts /var/lib/postgresql/.ssh
  chown postgres: /var/lib/postgresql/.ssh/known_hosts

  exit 0

fi


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
