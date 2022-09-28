# luajit-pwn

This is a story about a ctf challenge, language interpreter and a researcher who wanted to take it one step further :)

To get the entire context, see my [JIT-Shellcoding blogpost](https://0xbigshaq.github.io/2022/09/27/lua-jit-part3/).

To read the full series: [https://0xbigshaq.github.io/2022/08/22/lua-jit-intro/](https://0xbigshaq.github.io/2022/08/22/lua-jit-intro/)

In this repo, you'll find:
* `exploit.lua`: A demo of a shellcoding technique in LuaJIT
* `build-env.sh`: Automated build script to create a vuln-dev environment
* `luajit-expdev.c`: A lab(previously, defcon chall) that gives you a nice primitive: it allows you to control a function pointer to a JIT'ed trace

The generator script for `exploit.lua` can be found [here](https://0xbigshaq.github.io/2022/09/27/lua-jit-part3/#final-exploit) (should be uploaded soon to this repo as well)

# Build

To build, just run `./build-env.sh` and you'll end up with the following files in the repo's root directory:

```diff
$ ls
build-env.sh
exploit.lua
+ libluajit-5.1.so.2
+ LuaJIT-2.1.0-beta3/
+ luajit-expdev
luajit-expdev.c
README.md
+ v2.1.0-beta3.tar.gz
```


# Run

You might get an error('_error while loading shared libraries: libluajit-5.1.so.2_'), just set `LD_LIBRARY_PATH` to the current directory so the dynamic linker will know where to load the luajit lib from.

Example:
```
$ export LD_LIBRARY_PATH=.

$ ./luajit-expdev exploit.lua 
INSPECTION: This ship's JIT cargo was found to be 0x7f30a03dfd45
... yarr let ye apply a secret offset, cargo is now 0x7f30a03dfdf9 ...
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
...
```

(Tested on: Ubuntu 20.04)