#!/bin/bash
set -e

/etc/init.d/ssh start
echo "export PATH=/usr/lib/postgresql/15/bin/:$PATH" >> /var/lib/postgresql/.bashrc
echo "export PGDATA=/var/lib/postgresql/15/main/" >> /var/lib/postgresql/.bashrc
echo "export PG_COLOR=always" >> /var/lib/postgresql/.bashrc
echo "alias ll='ls -l --color'" >> /var/lib/postgresql/.bashrc
cp /var/lib/postgresql/.bashrc /var/lib/postgresql/.bash_profile
chown postgres: /var/lib/postgresql/.bash*


WHAT_AM_I=${WHAT_AM_I:-primary}

if [[ $WHAT_AM_I == 'bastion' ]]; then
  # Automatically accept ssh fingerprint
  ssh-keyscan -H bastion  >> ~/.ssh/known_hosts
  ssh-keyscan -H pg_red   >> ~/.ssh/known_hosts
  ssh-keyscan -H pg_green >> ~/.ssh/known_hosts
  ssh-keyscan -H pg_blue  >> ~/.ssh/known_hosts
  cp ~/.ssh/known_hosts /var/lib/postgresql/.ssh
  chown postgres: /var/lib/postgresql/.ssh/known_hosts

  exit 0

fi

cp /etc/postgresql/15/main/postgresql.conf.*     /etc/postgresql/15/main/
if [[ $WHAT_AM_I == 'primary' ]]; then
  cp /etc/postgresql/15/main/postgresql.conf.primary     /etc/postgresql/15/main/postgresql.conf
else
  cp /etc/postgresql/15/main/postgresql.conf.secondary   /etc/postgresql/15/main/postgresql.conf
  if [[ $RECOVERY_MIN_APPLY_DELAY -ne 0 ]]; then
    echo "recovery_min_apply_delay = $RECOVERY_MIN_APPLY_DELAY" >> /etc/postgresql/15/main/postgresql.conf
  fi
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
