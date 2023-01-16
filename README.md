# pgPlayground

Disclaimer: I do know, what I do about tag in Docker image is wrong.
<br>One more reson not to use this example in anything more than a playground.
<br>(Plus, I have no intention to ever publish this image, so... :-P )

## Quick start
### Build
```
$ cd build
$ ./build.sh
$ cd -
```

### Start
```
$ docker-compose up -d
$ docker-compose ps
```

### Play
```
$ docker exec -it pgplayground-bastion-1 bash

$ psql -h 127.0.0.1 -Uwiwwo -p5445 postgres
```

```
$ docker exec -it pgplayground-bastion-1 bash
root@bastion:/# ssh pg_red
Warning: Permanently added the ECDSA host key for IP address '172.19.0.3' to the list of known hosts.
Linux pg_red 5.15.49-linuxkit #1 SMP Tue Sep 13 07:51:46 UTC 2022 x86_64

root@pg_red:~#
```

```
$ docker exec -it pgplayground-bastion-1 bash
root@bastion:/# psql -hpg_red -Uwiwwo postgres
psql (15.1 (Debian 15.1-1.pgdg110+1))
SSL connection (protocol: TLSv1.3, cipher: TLS_AES_256_GCM_SHA384, compression: off)
Type "help" for help.

postgres=#
```

####  Promote
```
$ docker exec -it pgplayground-bastion-1 bash
root@bastion:/# ssh postgres@pg_blue
Warning: Permanently added the ECDSA host key for IP address '172.19.0.4' to the list of known hosts.
Linux pg_blue 5.15.49-linuxkit #1 SMP Tue Sep 13 07:51:46 UTC 2022 x86_64

postgres@pg_blue:~$ pg_ctl -D $PGDATA promote
waiting for server to promote.... done
server promoted


postgres@pg_blue:~$ tail -20 /var/log/postgresql/postgresql-15-main.log
2023-01-16 12:18:50.333 UTC [47] LOG:  starting PostgreSQL 15.1 (Debian 15.1-1.pgdg110+1) on x86_64-pc-linux-gnu, compiled by gcc (Debian 10.2.1-6) 10.2.1 20210110, 64-bit
2023-01-16 12:18:50.333 UTC [47] LOG:  listening on IPv4 address "0.0.0.0", port 5432
2023-01-16 12:18:50.333 UTC [47] LOG:  listening on IPv6 address "::", port 5432
2023-01-16 12:18:50.336 UTC [47] LOG:  listening on Unix socket "/var/run/postgresql/.s.PGSQL.5432"
2023-01-16 12:18:50.340 UTC [50] LOG:  database system was interrupted; last known up at 2023-01-16 12:18:48 UTC
2023-01-16 12:18:50.499 UTC [50] LOG:  entering standby mode
2023-01-16 12:18:50.502 UTC [50] LOG:  redo starts at 0/2000028
2023-01-16 12:18:50.503 UTC [50] LOG:  consistent recovery state reached at 0/20001B0
2023-01-16 12:18:50.503 UTC [47] LOG:  database system is ready to accept read-only connections
2023-01-16 12:18:50.514 UTC [51] LOG:  started streaming WAL from primary at 0/3000000 on timeline 1
2023-01-16 12:19:03.071 UTC [50] LOG:  received promote request
2023-01-16 12:19:03.071 UTC [51] FATAL:  terminating walreceiver process due to administrator command
2023-01-16 12:19:03.071 UTC [50] LOG:  invalid record length at 0/4000060: wanted 24, got 0
2023-01-16 12:19:03.071 UTC [50] LOG:  redo done at 0/4000028 system usage: CPU: user: 0.00 s, system: 0.00 s, elapsed: 12.56 s
2023-01-16 12:19:03.074 UTC [50] LOG:  selected new timeline ID: 2
2023-01-16 12:19:03.114 UTC [50] LOG:  archive recovery complete
2023-01-16 12:19:03.117 UTC [48] LOG:  checkpoint starting: force
2023-01-16 12:19:03.120 UTC [47] LOG:  database system is ready to accept connections
2023-01-16 12:19:03.125 UTC [48] LOG:  checkpoint complete: wrote 3 buffers (0.0%); 0 WAL file(s) added, 0 removed, 0 recycled; write=0.002 s, sync=0.001 s, total=0.009 s; sync files=2, longest=0.001 s, average=0.001 s; distance=32768 kB, estimate=32768 kB


postgres@pg_blue:~$ pgbench -i
dropping old tables...
NOTICE:  table "pgbench_accounts" does not exist, skipping
NOTICE:  table "pgbench_branches" does not exist, skipping
NOTICE:  table "pgbench_history" does not exist, skipping
NOTICE:  table "pgbench_tellers" does not exist, skipping
creating tables...
generating data (client-side)...
100000 of 100000 tuples (100%) done (elapsed 0.11 s, remaining 0.00 s)
vacuuming...
creating primary keys...
done in 0.34 s (drop tables 0.00 s, create tables 0.01 s, client-side generate 0.13 s, vacuum 0.08 s, primary keys 0.11 s).
postgres@pg_blue:~$
logout
Connection to pg_blue closed.

---

root@bastion:/# ssh postgres@pg_red
Warning: Permanently added the ECDSA host key for IP address '172.19.0.2' to the list of known hosts.
Linux pg_red 5.15.49-linuxkit #1 SMP Tue Sep 13 07:51:46 UTC 2022 x86_64

postgres@pg_red:~$ /etc/init.d/postgresql stop
Stopping PostgreSQL 15 database server: main.

postgres@pg_red:~$ pg_rewind -D $PGDATA --source-server="host=pg_blue port=5432 user=wiwwo password=wiwwo123 dbname=postgres" -P -R
pg_rewind: connected to server
pg_rewind: servers diverged at WAL location 0/4000060 on timeline 1
pg_rewind: rewinding from last common checkpoint at 0/2000110 on timeline 1
pg_rewind: reading source file list
pg_rewind: reading target file list
pg_rewind: reading WAL in target
pg_rewind: need to copy 82 MB (total source directory size is 101 MB)
84805/84805 kB (100%) copied
pg_rewind: creating backup label and updating control file
pg_rewind: syncing target data directory
pg_rewind: Done!

postgres@pg_red:~$ /etc/init.d/postgresql start
Starting PostgreSQL 15 database server: main.

postgres@pg_red:~$ tail -20 /var/log/postgresql/postgresql-15-main.log
2023-01-16 12:18:48.876 UTC [43] LOG:  checkpoint complete: wrote 0 buffers (0.0%); 0 WAL file(s) added, 0 removed, 0 recycled; write=0.001 s, sync=0.001 s, total=0.005 s; sync files=0, longest=0.000 s, average=0.000 s; distance=0 kB, estimate=8070 kB
2023-01-16 12:19:43.065 UTC [42] LOG:  received fast shutdown request
2023-01-16 12:19:43.067 UTC [42] LOG:  aborting any active transactions
2023-01-16 12:19:43.069 UTC [42] LOG:  background worker "logical replication launcher" (PID 48) exited with exit code 1
2023-01-16 12:19:43.069 UTC [43] LOG:  shutting down
2023-01-16 12:19:43.081 UTC [43] LOG:  checkpoint starting: shutdown immediate
2023-01-16 12:19:43.085 UTC [43] LOG:  checkpoint complete: wrote 0 buffers (0.0%); 0 WAL file(s) added, 0 removed, 0 recycled; write=0.001 s, sync=0.001 s, total=0.006 s; sync files=0, longest=0.000 s, average=0.000 s; distance=32767 kB, estimate=32767 kB
2023-01-16 12:19:43.093 UTC [42] LOG:  database system is shut down
2023-01-16 12:19:57.190 UTC [108] LOG:  starting PostgreSQL 15.1 (Debian 15.1-1.pgdg110+1) on x86_64-pc-linux-gnu, compiled by gcc (Debian 10.2.1-6) 10.2.1 20210110, 64-bit
2023-01-16 12:19:57.191 UTC [108] LOG:  listening on IPv4 address "0.0.0.0", port 5432
2023-01-16 12:19:57.191 UTC [108] LOG:  listening on IPv6 address "::", port 5432
2023-01-16 12:19:57.193 UTC [108] LOG:  listening on Unix socket "/var/run/postgresql/.s.PGSQL.5432"
2023-01-16 12:19:57.199 UTC [111] LOG:  database system was interrupted while in recovery at log time 2023-01-16 12:19:03 UTC
2023-01-16 12:19:57.199 UTC [111] HINT:  If this has occurred more than once some data might be corrupted and you might need to choose an earlier recovery target.
2023-01-16 12:19:57.306 UTC [111] LOG:  entering standby mode
2023-01-16 12:19:57.310 UTC [111] LOG:  redo starts at 0/20000D8
2023-01-16 12:19:57.337 UTC [111] LOG:  consistent recovery state reached at 0/4B76078
2023-01-16 12:19:57.337 UTC [111] LOG:  invalid record length at 0/4B76078: wanted 24, got 0
2023-01-16 12:19:57.337 UTC [108] LOG:  database system is ready to accept read-only connections
2023-01-16 12:19:57.346 UTC [112] LOG:  started streaming WAL from primary at 0/4000000 on timeline 2

postgres@pg_red:~$ psql
psql (15.1 (Debian 15.1-1.pgdg110+1))
Type "help" for help.


12:20:14 postgres@[local]/postgres
=# show primary_conninfo ;
                                                                      primary_conninfo
------------------------------------------------------------------------------------------------------------------------------------------------------------
 user=wiwwo password=wiwwo123 channel_binding=prefer host=pg_blue port=5432 sslmode=prefer sslcompression=0 sslsni=1 ssl_min_protocol_version=TLSv1.2 gssen.
.cmode=prefer krbsrvname=postgres target_session_attrs=any
(1 row)

Time: 0.212 ms

12:20:20 postgres@[local]/postgres
=# select count(1) from public.pgbench_accounts ;
  count
---------
 100,000
(1 row)

Time: 10.716 ms

12:20:28 postgres@[local]/postgres
=#
\q
postgres@pg_red:~$
logout
Connection to pg_red closed.

---

root@bastion:/# ssh postgres@pg_green
Warning: Permanently added the ECDSA host key for IP address '172.19.0.4' to the list of known hosts.
Linux pg_green 5.15.49-linuxkit #1 SMP Tue Sep 13 07:51:46 UTC 2022 x86_64

postgres@pg_green:~$ /etc/init.d/postgresql stop

postgres@pg_green:~$ sed -i 's/pg_red/pg_blue/g' $PGDATA/postgresql.auto.conf

postgres@pg_green:~$ pg_ctl -D $PGDATA start
waiting for server to shut down.... done
server stopped
waiting for server to start....
2023-01-16 13:05:44.077 UTC [74] LOG:  starting PostgreSQL 15.1 (Debian 15.1-1.pgdg110+1) on x86_64-pc-linux-gnu, compiled by gcc (Debian 10.2.1-6) 10.2.1 20210110, 64-bit
2023-01-16 13:05:44.078 UTC [74] LOG:  listening on IPv4 address "0.0.0.0", port 5432
2023-01-16 13:05:44.078 UTC [74] LOG:  listening on IPv6 address "::", port 5432
2023-01-16 13:05:44.081 UTC [74] LOG:  listening on Unix socket "/var/run/postgresql/.s.PGSQL.5432"
2023-01-16 13:05:44.086 UTC [77] LOG:  database system was shut down in recovery at 2023-01-16 13:05:43 UTC
2023-01-16 13:05:44.086 UTC [77] LOG:  entering standby mode
2023-01-16 13:05:44.090 UTC [77] LOG:  redo starts at 0/20000D8
2023-01-16 13:05:44.090 UTC [77] LOG:  consistent recovery state reached at 0/20001B0
2023-01-16 13:05:44.090 UTC [77] LOG:  invalid record length at 0/4000060: wanted 24, got 0
2023-01-16 13:05:44.090 UTC [74] LOG:  database system is ready to accept read-only connections
2023-01-16 13:05:44.102 UTC [78] LOG:  fetching timeline history file for timeline 2 from primary server
2023-01-16 13:05:44.105 UTC [78] LOG:  started streaming WAL from primary at 0/4000000 on timeline 1
2023-01-16 13:05:44.105 UTC [78] LOG:  replication terminated by primary server
2023-01-16 13:05:44.105 UTC [78] DETAIL:  End of WAL reached on timeline 1 at 0/4000060.
2023-01-16 13:05:44.106 UTC [78] FATAL:  terminating walreceiver process due to administrator command
2023-01-16 13:05:44.106 UTC [77] LOG:  new target timeline is 2
2023-01-16 13:05:44.118 UTC [79] LOG:  started streaming WAL from primary at 0/4000000 on timeline 2
 done
server started

postgres@pg_green:~$ psql
psql (15.1 (Debian 15.1-1.pgdg110+1))
Type "help" for help.


13:06:14 postgres@[local]/postgres
=# show primary_conninfo ;
                                                                      primary_conninfo
------------------------------------------------------------------------------------------------------------------------------------------------------------
 user=repl_user passfile='/var/lib/postgresql/.pgpass' channel_binding=prefer host=pg_blue port=5432 sslmode=prefer sslcompression=0 sslsni=1 ssl_min_proto.
.col_version=TLSv1.2 gssencmode=prefer krbsrvname=postgres target_session_attrs=any
(1 row)

Time: 0.290 ms

13:06:23 postgres@[local]/postgres
=#
\q
postgres@pg_green:~$
logout
Connection to pg_green closed.

---

root@bastion:/#
root@bastion:/#
root@bastion:/#
root@bastion:/# ssh postgres@pg_green
Linux pg_green 5.15.49-linuxkit #1 SMP Tue Sep 13 07:51:46 UTC 2022 x86_64

postgres@pg_green:~$ pg_ctl -D $PGDATA stop
waiting for server to shut down.... done
server stopped


postgres@pg_green:~$ rm -rf $PGDATA

postgres@pg_green:~$ pg_basebackup -D $PGDATA -h pg_blue -Uwiwwo

postgres@pg_green:~$ pg_ctl -D $PGDATA start
waiting for server to start....2023-01-16 13:58:53.472 UTC [4316] LOG:  starting PostgreSQL 15.1 (Debian 15.1-1.pgdg110+1) on x86_64-pc-linux-gnu, compiled by gcc (Debian 10.2.1-6) 10.2.1 20210110, 64-bit
2023-01-16 13:58:53.473 UTC [4316] LOG:  listening on IPv4 address "127.0.0.1", port 5432
2023-01-16 13:58:53.473 UTC [4316] LOG:  could not bind IPv6 address "::1": Cannot assign requested address
2023-01-16 13:58:53.476 UTC [4316] LOG:  listening on Unix socket "/var/run/postgresql/.s.PGSQL.5432"
2023-01-16 13:58:53.481 UTC [4319] LOG:  database system was interrupted; last known up at 2023-01-16 13:58:44 UTC
2023-01-16 13:58:53.603 UTC [4319] LOG:  redo starts at 0/7000028
2023-01-16 13:58:53.605 UTC [4319] LOG:  consistent recovery state reached at 0/7000100
2023-01-16 13:58:53.605 UTC [4319] LOG:  redo done at 0/7000100 system usage: CPU: user: 0.00 s, system: 0.00 s, elapsed: 0.00 s
2023-01-16 13:58:53.636 UTC [4317] LOG:  checkpoint starting: end-of-recovery immediate wait
2023-01-16 13:58:53.644 UTC [4317] LOG:  checkpoint complete: wrote 3 buffers (0.0%); 0 WAL file(s) added, 0 removed, 1 recycled; write=0.003 s, sync=0.001 s, total=0.010 s; sync files=2, longest=0.001 s, average=0.001 s; distance=16384 kB, estimate=16384 kB
2023-01-16 13:58:53.648 UTC [4316] LOG:  database system is ready to accept connections
 done
server started
postgres@pg_green:~$ psql
psql (15.1 (Debian 15.1-1.pgdg110+1))
Type "help" for help.


13:58:55 postgres@[local]/postgres
=# show primary_conninfo ;
                                                                      primary_conninfo
------------------------------------------------------------------------------------------------------------------------------------------------------------
 user=repl_user passfile='/var/lib/postgresql/.pgpass' channel_binding=prefer host=pg_blue port=5432 sslmode=prefer sslcompression=0 sslsni=1 ssl_min_proto.
.col_version=TLSv1.2 gssencmode=prefer krbsrvname=postgres target_session_attrs=any
(1 row)

Time: 0.268 ms

13:58:58 postgres@[local]/postgres
=#
\q

postgres@pg_green:~$
logout
Connection to pg_green closed.

root@bastion:/#


```

Interesting: `pg_basebackup` can be ran against a replica, and will still follow the correct primary:
```
root@bastion:/#
root@bastion:/# ssh postgres@pg_green
Linux pg_green 5.15.49-linuxkit #1 SMP Tue Sep 13 07:51:46 UTC 2022 x86_64

postgres@pg_green:~$ pg_ctl -D $PGDATA stop
waiting for server to shut down.... done
server stopped

postgres@pg_green:~$ rm -rf $PGDATA

postgres@pg_green:~$ pg_basebackup -D $PGDATA -h pg_red -Uwiwwo

postgres@pg_green:~$ pg_ctl -D $PGDATA start
waiting for server to start....2023-01-16 14:01:05.518 UTC [4346] LOG:  starting PostgreSQL 15.1 (Debian 15.1-1.pgdg110+1) on x86_64-pc-linux-gnu, compiled by gcc (Debian 10.2.1-6) 10.2.1 20210110, 64-bit
2023-01-16 14:01:05.518 UTC [4346] LOG:  listening on IPv4 address "127.0.0.1", port 5432
2023-01-16 14:01:05.518 UTC [4346] LOG:  could not bind IPv6 address "::1": Cannot assign requested address
2023-01-16 14:01:05.522 UTC [4346] LOG:  listening on Unix socket "/var/run/postgresql/.s.PGSQL.5432"
2023-01-16 14:01:05.527 UTC [4349] LOG:  database system was interrupted while in recovery at log time 2023-01-16 13:58:44 UTC
2023-01-16 14:01:05.527 UTC [4349] HINT:  If this has occurred more than once some data might be corrupted and you might need to choose an earlier recovery target.
2023-01-16 14:01:05.648 UTC [4349] LOG:  entering standby mode
2023-01-16 14:01:05.651 UTC [4349] LOG:  redo starts at 0/7000028
2023-01-16 14:01:05.652 UTC [4349] LOG:  consistent recovery state reached at 0/70000D8
2023-01-16 14:01:05.652 UTC [4346] LOG:  database system is ready to accept read-only connections
2023-01-16 14:01:05.653 UTC [4349] LOG:  invalid record length at 0/8000060: wanted 24, got 0
2023-01-16 14:01:05.664 UTC [4350] LOG:  started streaming WAL from primary at 0/8000000 on timeline 2
 done
server started

postgres@pg_green:~$ psql
psql (15.1 (Debian 15.1-1.pgdg110+1))
Type "help" for help.

14:01:08 postgres@[local]/postgres
=# show primary_conninfo ;
                                                                      primary_conninfo
------------------------------------------------------------------------------------------------------------------------------------------------------------
 user=wiwwo password=wiwwo123 channel_binding=prefer host=pg_blue port=5432 sslmode=prefer sslcompression=0 sslsni=1 ssl_min_protocol_version=TLSv1.2 gssen.
.cmode=prefer krbsrvname=postgres target_session_attrs=any
(1 row)

Time: 0.641 ms
```


### Leave
```
$ docker-compose kill
$ docker-compose rm
```


## Users
**All users have pwd= \<username\>123, eg `wiwwo` pwd `wiwwo123`**
<br><br>Available linux users: `root`, `postgres`
<br>Available postgres users: `postgres`, `wiwwo`, `repl_user`
