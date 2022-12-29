# pgPlayground

## Quick start
### Build
```
$ cd build
$ ./build/build
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


### Leave
```
$ docker-compose kill
$ docker-compose rm
```


## Users
**All users have pwd= <username>123, eg `wiwwo` pwd `wiwwo123`**
<br><br>Available linux users: `root`, `postgres`
<br>Available postgres users: `postgres`, `wiwwo`, `repl_user`
