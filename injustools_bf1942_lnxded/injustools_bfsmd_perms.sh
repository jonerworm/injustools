#!/bin/sh
USU='bf1942'
GRU='bf1942'
if [ "$1" != '' ]; then
	BF42DIR="$1"
	shift
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
			chmod ug+x `echo -n "${FILEDIR}" | cut -d: -f1`
			;;
	esac
done
grep -v ^\# <<_EoF_ | while read FILEDIR; do touch "$FILEDIR"; chmod g+w "${FILEDIR}"; done
#${BF42DIR}
${BF42DIR}bfsmd.log
_EoF_

