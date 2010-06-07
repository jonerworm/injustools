#!/bin/sh
#
# This script installs BF1942 GNU/Linux dedicated server and
# BF1942 Server Manager (BFSMD), downloading, checking,
# installing, patching, modding.
#
# $1 = optional directory where to install (default = /usr/local/games/bf1942)
#
# Copyright (C) 2010, Joner Cyrre Worm
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

DEFAULT_URI='http://99.198.122.92/~injustos/download'
DEFAULT_MASK="~injustos"
exec 4>&2
exec 3>&1
VERBOSE=0
QUIET=0
if [ "$1" == '-h' -o "$1" == '--help' ]; then
	(
	echo -e "Usage:\n"`basename "$0"`" [ -h | --help | -q | --quiet | -v | --verbose ] [ <mod_selection_flags> ] [ <install_directory> ]"
	echo -e "mod_selection_flags = --no-dc | --no-dcf | --no-eod | --no-fh"
	echo -e "                      dc  = Desert Combat 0.7"
	echo -e "                      dcf = Desert Combat Final 0.8"
	echo -e "                      eod = Eve of Destruction Classic"
	echo -e "                      fh  = Forgotten Hope"
	echo -e "\nCopyright (C) 2010, Joner Cyrre Worm\nThis program is licensed under the GNU General Public License\nas published by the Free Software Foundation. See COPYING file."
	) >&2
	exit
fi

if [ "$1" == '-v' -o "$1" == '--verbose' ]; then
	shift
	VERBOSE=1
	exec 2>&4
	exec 1>&3
elif [ "$1" == '-q' -o "$1" == '--quiet' ]; then
	shift
	QUIET=1
	exec 4>/dev/null
	exec 3>/dev/null
	exec 2>/dev/null
	exec 1>/dev/null
fi
NODC=0
NODCF=0
NOEOD=0
NOFH=0

while [ $# -gt 0 ]
do
	ARG="$1"
	case "$ARG" in
		--no-dc)
			NODC=1
			NODCF=1
			shift
			;;
		--no-dcf)
			NODCF=1
			shift
			;;
		--no-fh)
			NODCF=1
			shift
			;;
		--no-eod)
			echo "oh noooo... you should try Eve of Destruction Classic!" >&2
			NOEOD=1
			shift
			;;
		*)
			break 2
			;;
	esac
done

export DEFAULT_URI DEFAULT_MASK VERBOSE QUIET

#
# echo_ok - Echoes the final string for an action, according to previous
#           return code given as a parameter
#
# $1 = previous return code
#
echo_ok() {

RCOK=$1; shift
[ $RCOK -eq 0 ] && echo -n " OK " || echo -n " failed ($RCOK) "

}

#
# check_md5sum - For a given file checks against an existing MD5 correspondent
#                check file (if exists), or create an MD5 check file (if doesn't
#                already exists).
# $1 = path to a file to check, or generate MD5 check file.
#
check_md5sum() {

	MD5_FILE="$1"; shift
	RC5=0
	if [ -e "${MD5_FILE}.md5" ]; then
		echo -ne "\n\t\t\tValidating checksum..."
		md5sum -c "${MD5_FILE}.md5" >/dev/null 2>&1
	else
		echo -ne "\n\t\t\tCreating checksum..." >&3
		md5sum "$MD5_FILE" >"${MD5_FILE}.md5" >/dev/null 2>&1
	fi
	RC5=$?
	echo_ok $RC5
	return $RC5

}

#
# check_file - Checks the integrity of archive files either by their
#              magic-numbers' mime - file (8) -, file extension, MD5 check,
#              archive test (when supported by CLI command), or null extraction.
#
# $1 = file extension
# $2 = file type (mime)
# $3 = file subtype (embed mime)
# $4 = path to a file to check
#
check_file() {
echo -ne "\n\t\tChecking integrity..."
FILE_EXT="$1"; shift
FILE_TYPE="$1"; shift
FILE_STYPE="$1"; shift
FILE="$1"; shift

RCF=0

FILE_MIME['tar']='application/x-tar'
FILE_MIME['tgz']='application/x-tar'
FILE_MIME['bz2']='application/x-bzip2'
FILE_MIME['gz']='application/x-gzip'
FILE_MIME['zip']='application/x-zip'
FILE_MIME['sh']='application/x-shellscript'
FILE_MIME['bin']='application/x-executable'
FILE_MIME['other']="${FILE_TYPE}"

if [ "$FILE_TYPE" != "${FILE_MIME[${FILE_EXT}]}" ]; then
	echo -ne " mime type ($FILE_TYPE} not compatible with file extention ($FILE_EXT) "
	RCF=-1
else
	case "$FILE_EXT" in
		'tar')
			# if [ "$FILE_STYPE" == "${FILE_MIME['gz']}" ]; then
			if [ "$FILE_STYPE" == "application/x-gzip" ]; then
				echo -ne " mime type ($FILE_TYPE} not compatible with file extention ($FILE_EXT) "
				false
			else
				tar xf "$FILE" -O >/dev/null 2>&1
			fi
			;;
		'tgz')
			# if [ "$FILE_STYPE" != "${FILE_MIME['gz']}" ]; then
			if [ "$FILE_STYPE" != "application/x-gzip" ]; then
				echo -ne " mime type ($FILE_TYPE} not compatible with file extention ($FILE_EXT) "
				false
			else
				tar xzf "$FILE" -O >/dev/null 2>&1
			fi
			;;
		'bz2')
			bzip2 -q -t "$FILE" >/dev/null 2>&1
			;;
		'gz')
			gunzip -q -t "$FILE" >/dev/null 2>&1
			;;
		'zip')
			unzip -q -t "$FILE" >/dev/null 2>&1
			;;
		'sh')
			sh "$FILE" --help 2>&1 | grep -i -q '^makeself' >/dev/null 2>&1
			if [ $? -eq 0 ]; then
				sh "$FILE" --check >/dev/null 2>&1
			else
				true
			fi
			;;
		*)
			;;
	esac
	RCF=$?
	echo_ok $RCF
	if [ $RCF -eq 0 ]; then
		check_md5sum "$FILE"
		RCF=$?
	else
		echo " file maybe is corrupted "
	fi
fi


return $RCF
}

#
# gotcha - Download and check a file
#
# $1 = path to a file do download and check
# $* = URLs available to download
#
gotcha() {
	TRIES=3
	ARQ="$1"; shift
	if echo "$*" | grep -q "$DEFAULT_MASK" >/dev/null 2>&1; then
	eval
	else
		gotcha "$ARQ" $* "$DEFAULT_URI/$ARQ"
	return $?
	fi
	echo -ne "\nDonwloading \"$ARQ\""
	RC=0
	while [ $# -gt 0 ]
	do
	# rm -f "$ARQ"
	RC=0
	URL="$1"; shift
	echo -ne "\n\tfrom \"$URL\" "
	wget --retry-connrefused -t $TRIES -q -c -O "$ARQ" "$URL" >/dev/null 2>&1
	RC=$?
	echo_ok $RC
	[ $RC -ne 0 ] && continue
	TYPE=`file -bzip "$ARQ" | cut -d\; -f1`
	SUBTYPE=`echo "$TYPE" | cut -d\, -f2 | cut -d\( -f2 | cut -d\) -f1`
	TYPE=`echo "$TYPE" | cut -d\, -f1`
	case "$ARQ" in
		*.tar.gz|*.tgz)
			check_file 'tgz' "$TYPE" "$SUBTYPE" "$ARQ" && break
			;;
		*.tar)
			check_file 'tar' "$TYPE" "$SUBTYPE" "$ARQ" && break
			;;
		*.bz2)
			check_file 'bz2' "$TYPE" "$SUBTYPE" "$ARQ" && break
			;;
		*.gz)
			check_file 'gz' "$TYPE" "$SUBTYPE" "$ARQ" && break
			;;
		*.zip)
			check_file 'zip' "$TYPE" "$SUBTYPE" "$ARQ" && break
			;;
		*.run|*.sh)
			check_file 'sh' "$TYPE" "$SUBTYPE" "$ARQ" && break
			;;
		*.bin)
			check_file 'bin' "$TYPE" "$SUBTYPE" "$ARQ" && break
			;;
		*)
			case "$TYPE" in
				"application/x-tar")
					if [ "$SUBTYPE" == 'application/x-gzip' ]; then
						check_file 'tgz' "$TYPE" "$SUBTYPE" "$ARQ" && break
					else
						check_file 'tar' "$TYPE" "$SUBTYPE" "$ARQ" && break
					fi
					;;
				"application/x-bzip2")
					check_file 'bz2' "$TYPE" "$SUBTYPE" "$ARQ" && break
					;;
				"application/x-gzip")
					check_file 'gz' "$TYPE" "$SUBTYPE" "$ARQ" && break
					;;
				"application/x-zip")
					check_file 'zip' "$TYPE" "$SUBTYPE" "$ARQ" && break
					;;
				"text/html")
					echo -ne " error: downloaded a web page "
					RC=-1
					rm -f "$ARQ"
					continue
					;;
				*)
					check_file 'other' "$TYPE" "$SUBTYPE" "$ARQ" && break
					;;
			esac
			;;
	esac
	RC=-1
	rm -f "$ARQ"
	done
	[ $RC -eq 0 ] && echo "OK"
	return $RC
}

#
# link_mixedcase - create various mixedcase symbolic links to
#                  one all-lowercase directory.
#
# $1 = directory where symbolic links will be created
# $* = symbolic link names that will point to lowercase dir
#
link_mixedcase() {
	RC=0
	DIR=`dirname "$1"` | ; shift
	while [ $# -gt 0 ]
	do
	MCDIR="$1"; shift
	LCDIR=`basename "$MCDIR" | tr '[:upper:]' '[:lower:]'`
	LINKTARG="$DIR/$LCDIR"
	LINK="$DIR/$MCDIR"
	if [ ! -e "$LINKTARG" ]; then
			echo "cannot find link target at $LINKTARG" >&2
			RC=-1
		else
			if [ -e "$LINK" -a ! -l "$LINK" ]; then
				echo "\"$LINK\" already exists and is not a link"
				RC=-1
			else
				rm -f "$LINK" >/dev/null 2>&1
				ln -s "$LCDIR" "$LINK"
				RC=$?
			fi
		fi
	done
	return $RC
}

if [ -s "$1" ]; then
	BFDIR="$1"; shift
else
	BFDIR='/usr/local/games/bf1942'
fi

BFINJ="injustools_bf1942_lnxded.tgz"
gotcha "${BFINJ}" "$DEFAULT_URI/$BFINJ"

echo -ne "\nExtracting ${BFINJ}..."
tar xzf "$BFINJ" --exclude "*"`basename "$0"` >/dev/null 2>&1
echo_ok $?

BFSERVER='Battlefield_1942_1.6_Dedicated_Server_Linux.run'
gotcha "${BFSERVER}" "http://www.battlefielddownloads.com/index.php?dir=Battlefield_1942/Servidor_Dedicado/&file=${BFSERVER}" "$DEFAULT_URI/bf1942_linux-dedicado-1.6-rc2.run"

BFSRVPATCH='Battlefield_1942_1.61_Patch_Dedicated_Server_Linux.tar.gz'
gotcha "$BFSRVPATCH" "http://www.battlefielddownloads.com/index.php?dir=Battlefield_1942/Servidor_Dedicado/&file=${BFSRVPATCH}"

EODMOD='eod_classic_210_server.zip'
[ $NOEOD -eq 0 ] && gotcha "${EODMOD}" "http://www.lottimax.de/eodmod/releases/${EODMOD}"

DCMOD='Desert_Combat_0.7_Full_Dedicated_Server_Linux.run'

if [ $NODC -eq 0 ]; then
	gotcha "$DCMOD" "http://www.battlefielddownloads.com/index.php?dir=Battlefield_1942/Mods/Desert_Combat/Servidor_Dedicado/&file=$DCMOD"
	DCFINAL='Desert_Combat_Final_Patch_Dedicated_Server_Linux.run'
	[ $NODCF -eq 0 ] && gotcha "$DCFINAL" "http://www.battlefielddownloads.com/index.php?dir=Battlefield_1942/Mods/Desert_Combat/Servidor_Dedicado/&file=$DCFINAL"

FHMOD='Forgotten_Hope_0.7_Dedicated_Server_Windows_and_Linux.zip'
[ $NOFH -eq 0 ] &&  gotcha "$FHMOD" "http://www.battlefielddownloads.com/index.php?dir=Battlefield_1942/Mods/Forgotten_Hope/Servidor_Dedicado/&file=$FHMOD"

BFSM='BFServerManager201.tgz'
gotcha "${BFSM}" "http://www.bf-games.net/downloadnow/204/19346"

echo -ne "\nInstalling BF1942 server..."
mkdir -p "${BFDIR}"

# mkdir -p "$BFDIR"
tee expect.out <<_expect_EoF_ | expect >/dev/null
set timeout 90
spawn sh "$BFSERVER" --nox11
sleep 5
expect "ress return to continue" {send "\r"; sleep 5; send "q"}
expect -gl "accept*or*decline" {send "accept\r"}
expect "ress return to continue" {send "\r"; sleep 5; send "q"}
expect -gl "yes*or*no" {send "yes\r"}
expect "nter your target installation directory" {send "$BFDIR\r"}
set timeout 30
expect "nstallation complete" close
exit
_expect_EoF_

RC=$?
echo_ok $RC

echo -ne "\nExtracting BF1942 server patch..."
tar xzf "${BFSRVPATCH}" -C "$BFDIR" >/dev/null 2>&1
RC=$?
echo_ok $RC

link_mixedcase "${BFDIR}/bf1942" Mods MODS
link_mixedcase "${BFDIR}/bf1942/mods" BF1942

if [ $NOEOD -eq 0 ]; then
	if [ -r "$EODMOD" ]; then
		echo -ne "\nExtracting Eve of Destruction mod..."
		unzip -q -o "${EODMOD}" -d "$BFDIR/bf1942/mods" >/dev/null 2>&1
		RC=$?
		if [ $RC -ne 0 ]; then
			echo_ok $RC)
		else
			link_mixedcase "${BFDIR}/bf1942/mods" Eod EoD EOD
		fi
	fi
fi

if [ $NODC -eq 0 ]; then
	if [ -r "$DCMOD" ]; then
		echo -ne "\nInstalling DesertCombat mod..."
		sh "./$DCMOD" --nox11 --noexec --target "$BFDIR/bf1942" >/dev/null 2>&1
		RC=$?
		echo_ok $RC
		[ $NODCF -eq 0 -a $RC -eq 0 ] && [ -r "$DCFINAL" ] && (echo -ne "\nInstalling DC Final mod..."; sh "./$DCFINAL" --nox11 --noexec --target "$BFDIR/bf1942/mods" >/dev/null 2>&1; RC=$?; echo_ok $RC)
	fi
fi

[ $NOFH -eq 0 ] && [ -r "$FHMOD" ] && (echo -ne "\nExtracting Forgotten Hope mod..."; unzip -q -o "${FHMOD}" -d "$BFDIR/bf1942" >/dev/null 2>&1; RC=$?; echo_ok $RC)

mkdir -p "$BFDIR/bfsmd"
echo -ne "\nExtracting BFServerManager..."
tar xzf "$BFSM" -C "$BFDIR/bfsmd" >/dev/null 2>&1
echo_ok $?

[ -r "$BFINJ" ] || echo "$0: $BFINJ not found" || exit -1
echo -ne "\nCorrecting permissions..."
sh ./injustools_bf1942_perms.sh "$BFDIR"
sh ./injustools_bfsmd_perms.sh "$BFDIR/bfsmd"
#   sh ./injustools_bf1942_jail.sh "$BFDIR"
echo_ok $?

echo -ne "\nInstalling BFSM daemon..."
RC=0
for i in bfsmd
do
	install -g root -o root -m 0664 -T injustools_${i}_sysconfig /etc/sysconfig/${i} >/dev/null 2>&1
	let "RC=RC+$?"
	install -g root -o root -m 0750 -T injustools_${i}_rc /etc/init.d/${i} >/dev/null 2>&1
	let "RC=RC+$?"
done
echo_ok $RC

[ $RC -eq 0 ] && chkconfig --add bfsmd

