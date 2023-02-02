#!/bin/bash
set -e

/etc/init.d/ssh start
echo "export PATH=/usr/lib/postgresql/15/bin/:$PATH" >> /var/lib/postgresql/.bashrc
echo "export PGDATA=/var/lib/postgresql/15/main/" >> /var/lib/postgresql/.bashrc
echo "export PG_COLOR=always" >> /var/lib/postgresql/.bashrc
echo "alias ll='ls -l --color'" >> /var/lib/postgresql/.bashrc
cp /var/lib/postgresql/.bashrc /var/lib/postgresql/.bash_profile
chown postgres: /var/lib/postgresql/.bash*

echo "alias ll='ls -l --color'" >> /root/.bashrc

WHAT_AM_I=${WHAT_AM_I:-primary}
echo "I am $WHAT_AM_I"

# Automatically accept ssh fingerprint
ssh-keyscan -H bastion  >> ~/.ssh/known_hosts
ssh-keyscan -H pg_red   >> ~/.ssh/known_hosts
ssh-keyscan -H pg_green >> ~/.ssh/known_hosts
ssh-keyscan -H pg_blue  >> ~/.ssh/known_hosts
cp ~/.ssh/known_hosts /var/lib/postgresql/.ssh
chown postgres: /var/lib/postgresql/.ssh/known_hosts

if [[ $WHAT_AM_I == 'bastion' ]]; then

  exit 0

fi


if [[ $WHAT_AM_I == 'primary' ]]; then
  cp /etc/postgresql/15/main/postgresql.conf.primary     /etc/postgresql/15/main/postgresql.conf
else
  cp /etc/postgresql/15/main/postgresql.conf.replica     /etc/postgresql/15/main/postgresql.conf
  if [[ $RECOVERY_MIN_APPLY_DELAY -ne 0 ]]; then
    echo "Applying recovery_min_apply_delay = $RECOVERY_MIN_APPLY_DELAY"
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
    ALTER USER postgres ENCRYPTED PASSWORD 'postgres123';
    CREATE USER wiwwo LOGIN SUPERUSER ENCRYPTED PASSWORD 'wiwwo123';
    CREATE USER repl_user REPLICATION LOGIN ENCRYPTED PASSWORD 'repl_user123';

    GRANT EXECUTE ON function pg_catalog.pg_ls_dir(text, boolean, boolean) TO repl_user;
    GRANT EXECUTE ON function pg_catalog.pg_stat_file(text, boolean) TO repl_user;
    GRANT EXECUTE ON function pg_catalog.pg_read_binary_file(text) TO repl_user;
    GRANT EXECUTE ON function pg_catalog.pg_read_binary_file(text, bigint, bigint, boolean) TO repl_user;
EOSQL
  "
fi
