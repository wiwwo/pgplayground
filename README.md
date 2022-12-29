# pgPlayground

## Quick start
```
$ docker-compose build
$ docker-compose up -d
$ docker-compose ps

$ docker exec -it pgplayground-console-1 bash

$ psql -h 127.0.0.1 -Uwiwwo -p5445 postgres
```

```
$ docker exec -it pgplayground-console-1 bash
root@console:/# ssh pg_red
Warning: Permanently added the ECDSA host key for IP address '172.19.0.3' to the list of known hosts.
Linux pg_red 5.15.49-linuxkit #1 SMP Tue Sep 13 07:51:46 UTC 2022 x86_64

root@pg_red:~#
```

## Users
**All users have pwd= <username>123, eg `wiwwo` pwd `wiwwo123`**
<br>Available linux users: `root`, `postgres`
<br>Available postgres users: `postgres`, `wiwwo`, `repl_user`
