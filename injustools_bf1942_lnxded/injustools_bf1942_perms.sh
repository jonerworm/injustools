#!/bin/sh
USU='bf1942'
GRU='bf1942'
if [ "$1" != '' ]; then
	BF42DIR="$1"; shift
	[ `echo -n "$BF42DIR" | cut -b${#BF42DIR}` != '/' ] && BF42DIR="${BF42DIR}/"
	[ "${BF42DIR}" == '/' ] && (echo "Nao pode ser '/'" >&2 ; exit -1)
else
	BF42DIR='./'
fi
chown -R games.${GRU} "${BF42DIR}"
find "${BF42DIR}" -type d -exec chmod 2750 {} \;
find "${BF42DIR}" ! -type d -exec chmod 0640 {} \;
find "${BF42DIR}" ! -type d -exec file -p -i {} \; | \
while read FILEDIR MIME
do
	case "${MIME}" in
		*application/x-executable*|*application/x-shellscript*)
			EXECDIR=`echo -n "${FILEDIR}" | cut -d: -f1`
			chmod ug+x "$EXECDIR"
			;;
	esac
done
grep -v ^\# <<_EoF_ | while read FILEDIR; do touch "$FILEDIR"; chmod g+w "${FILEDIR}"; done
#${BF42DIR}
#${BF42DIR}pb
${BF42DIR}pb/pbbans.dat
${BF42DIR}mods/bf1942/logs
${BF42DIR}mods/bf1942/logs/bflog_local.log
#${BF42DIR}mods/bf1942/settings
${BF42DIR}mods/bf1942/settings/maplist.con
${BF42DIR}mods/bf1942/settings/bannedwords.con
${BF42DIR}mods/bf1942/settings/serverschedule.con
${BF42DIR}mods/bf1942/settings/maps.con
${BF42DIR}mods/bf1942/settings/adminsettings.con
${BF42DIR}mods/bf1942/settings/servermaplist.con
${BF42DIR}mods/bf1942/settings/playermenu.con
${BF42DIR}mods/bf1942/settings/announcements.con
${BF42DIR}mods/bf1942/settings/serverautoexec.con
${BF42DIR}mods/bf1942/settings/servermanager.con
${BF42DIR}mods/bf1942/settings/serverbanlist.con
${BF42DIR}mods/bf1942/settings/serversettings.con
${BF42DIR}mods/bf1942/settings/useraccess.con
${BF42DIR}mods/bf1942/settings/mods.con
${BF42DIR}mods/bf1942/settings/banlist.con
#${BF42DIR}mods/eod
${BF42DIR}mods/eod/logs
${BF42DIR}mods/eod/logs/bflog_local.log
${BF42DIR}bfsmd.log
_EoF_

