#!/bin/sh
ROOT_DIR="$1"
export ROOT_DIR
(
if [ "$ROOT_DIR" != '' ]; then
    mkdir -p "$ROOT_DIR" 2>/dev/null
    cd "$ROOT_DIR"
fi
[ -d bfsmd ] || cd bf1942 || ( echo "$0: Falta diretorio ${ROOT_DIR}/bf1942, verifique e corrija!"; exit -1 ) >&2
ROOT_DIR=`pwd`
[ -d proc ] && umount proc
rm -fr proc tmp etc bin sbin lib usr var/run
mkdir -p proc tmp etc bin sbin lib usr/{bin,sbin,lib,local/games,share} var/{run,log}
mount -t proc proc proc
chmod 1777 tmp
cp -pr /etc/{passwd,group,hosts,resolv.conf,nsswitch.conf,ld*,localtime,termcap} etc/
cp -prL /lib/{libc.so*,libdl.so*,ld-linux.so*,libm.so*,libpthread.so*,libtermcap.so*,libgcc_s.so*} lib/
cp -pL /usr/lib/{libncurses.so*,libform.so*,libmenu.so*,libpanel.so*} usr/lib/
cp -pL /usr/lib/{libncursesw.so*,libformw.so*,libmenuw.so*,libpanelw.so*,libstdc++.so*} usr/lib/
cp -pL /usr/bin/ld usr/bin
mkdir -p "./${ROOT_DIR}"
rmdir "./${ROOT_DIR}"
ln -s / "./${ROOT_DIR}"
find tmp etc bin sbin lib usr var -ls
cp -pr /usr/share/{tabset,terminfo,zoneinfo} usr/share/
ls -ld usr/share/{tabset,terminfo,zoneinfo}
)
