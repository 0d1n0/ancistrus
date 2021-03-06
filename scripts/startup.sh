#!/bin/sh
#
# ancistrus
#
# Netgear's D7000 Nighthawk Router Experience Distributed Project
#
# https://github.com/negan07/ancistrus
#
# License: GPLv2
#
#
# Startup script: initialize router for package installations.
#
# Usage: $0 (<url>)
#
# <url> parameter is optionally used only if remote urls are different from the built-in one.
# This script can be executed once and only once and it should be deleted after being run successfully.
#
# web-login the router and enable debug mode: http://${ROUTERLANIP}/setup.cgi?todo=debug
# telnet the router.
# login: 'admin' or 'root' on older firmwares.
# password: same as web gui interface.
#
# cd /etc
# curl -k -O https://raw.githubusercontent.com/negan07/ancistrus/master/scripts/startup.sh
# chmod 755 startup.sh
# ./startup.sh
# Follow the instructions on terminal.
#

ETCDIR=/etc
USRETCDIR=/usr${ETCDIR}
BINDIR=/usr/sbin

BIN=opkg
OPKG=${ETCDIR}/${BIN}
CONF=${OPKG}.conf
ARC=${OPKG}.zip
ABSARC=${BIN}.zip
TOINST="${BIN} zlib ancistrus-core utelnetd"

WWW=/www
LANGSDIR=${WWW}/langs

URL=https://raw.githubusercontent.com/negan07/ancistrus/gh-pages/tools/ancistrus-arm-D7000
[ ! -z "$1" ] && URL=$1

[ -x ${BINDIR}/${BIN} ] && echo "${BIN} looks already installed." && exit 3

cd ${ETCDIR}
echo "Cleaning up some garbage/orphan dirs & files..."
[ ! -z "`pidof telnetenabled`" ] && killall -9 telnetenabled
for D in "/opt" "${WWW}/cgi-bin"; do find $D -type d -name .svn -exec rm -rf '{}' \; > /dev/null 2>&1; done
for D in "CSY" "TUR"; do find ${LANGSDIR} -type d -name $D -exec rm -rf '{}' \; > /dev/null 2>&1; done
find ${LANGSDIR} -type f -name *.gz -exec rm -f '{}' \; > /dev/null 2>&1
rm -f ${OPKG} ${CONF} ${ARC} ${USRETCDIR}/rcS.MT ${BINDIR}/reaim ${BINDIR}/telnetenabled ${WWW}/language/Czech.js ${WWW}/*DGND*.jpg ${WWW}/vw_* ${WWW}/vpn_* ${WWW}/h_vpn* ${WWW}/h_vauto* ${WWW}/h_vman* ${WWW}/index1.htm ${WWW}/start1.htm ${WWW}/*_demo.htm ${WWW}/start_old_style.htm
sync
echo
echo "Downloading & extracting: ${ARC} ..."
curl -k -O ${URL}/${ABSARC}
unzip ${ARC}
[ $? -ne 0 -o ! -f ${OPKG} -o ! -f ${CONF} ] && echo "Problem has occurred: check either connection or download urls." && exit 2
chmod 755 ${OPKG}
chmod 644 ${CONF}
echo
echo "Installing essential packages: ${TOINST}"
${OPKG} update && sleep 1
for IPK in ${TOINST}
do
${OPKG} install ${IPK}
[ $? -ne 0 ] && echo "${IPK} installation failed: check repository urls on ${CONF}" && exit 1
sleep 1
done
rm -f ${OPKG} ${ARC}
sync
echo
echo "This script can now be deleted: type 'rm `basename $0`'"
exit 0
