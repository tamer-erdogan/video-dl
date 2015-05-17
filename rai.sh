#!/bin/bash
# Rai.TV download script
# Created by Daniil Gentili (http://daniil.eu.org)
# Changelog:
# v1 (and revisions): initial version.
# v2 (and revisions): added support for Rai Replay, support for multiple qualities, advanced video info and custom API server.
#

[ "$1" = "--help" ] && echo "Rai.tv download script
Created by Daniil Gentili
Usage: $(basename $0) [ -qmf [ urls.txt ] ] URL URL2 URL3 ...

Options:

-q	Quiet mode: useful for crontab jobs, automatically enables -a.
-a	Automatic mode: automatically download the video in the maximum quality.
-f	Reads URL(s) from specified text file(s).
--help	Show this extremely helpful message.

" && exit

[ "$*" = "" ] && echo "No url specified. Aborting." && exit 1

[ "$1" = "-q" ] && WOPT="-q" && shift
[ "$1" = "-a" ] && A=y && shift
[ "$1" = "-f" ] && F=y && shift
[ "$1" = "-qa" ] && WOPT="-q" && A=y && shift

[ "$1" = "-af" ] && A=y && F=y && shift

[ "$1" = "-qf" ] && WOPT="-q" && F=y && shift

[ "$1" = "-qaf" ] && WOPT="-q" && A=y && F=y && shift

[ "$1" = "-aq" ] && WOPT="-q" && A=y && shift
[ "$1" = "-fa" ] && A=y && F=y && shift
[ "$1" = "-fq" ] && WOPT="-q" && F=y && shift
[ "$1" = "-afq" ] && WOPT="-q" && A=y && F=y && shift
[ "$1" = "-faq" ] && WOPT="-q" && A=y && F=y && shift
[ "$1" = "-aqf" ] && WOPT="-q" && A=y && F=y && shift
[ "$WOPT" = "-q" ] && A=y
[ "$F" = "y" ] && URL="$(cat "$*")" || URL="$*"

echo -n "Self-updating script..." && wget http://daniilgentili.magix.net/rai.sh -O $0 -q 2>/dev/null ; echo -en "\r\033[K"

function var() {
eval $*
}


if [ "$A" = "y" ]; then

 function relinker_rai() {
dl="$(echo "$api" | awk 'END {print $NF}')"
ext=$(echo $url | awk -F. '$0=$NF')
queue="$queue
wget $dl -O $title.$ext $WOPT
"
 }
else

 echo "Video(s) info:" &&
 function dlcmd() {
videoTitolo=$(echo "$titles" | sed s/'\w*$'//)
max="$(echo "$api" | awk 'END{print}' | grep -Eo '^[^ ]+')"

echo "Title: $videoTitolo

$(echo "$api" | sed 's/http.*//')

"

until [ "$l" -le "$max" ] && [ "$l" -gt 0 ] ; do echo -n "What quality do you whish to download (number, enter q to skip this video)? "; read l; [ "$l" = "q" ] && break;done 2>/dev/null

[ "$l" = "q" ] && continue

url=$(echo "$api" | sed "$l!d" | awk 'NF>1{print $NF}')

ext=$(echo $url | awk -F. '$0=$NF')

queue="$queue
wget $url -O $title.$ext $WOPT
"
 }
fi


for u in $URL; do
 curl --version &>/dev/null && (curl -Ls -o /dev/null -w %{url_effective} $u | grep -qE 'http://www.*.rai..*/dl/RaiTV/programmi/media/*|http://www.*.rai..*/dl/RaiTV/tematiche/.*|http://www.*.rai..*/dl/.*PublishingBlock-.*|http://www.*.rai..*/dl/replaytv/replaytv.html.*|http://.*.rai.it/.*|http://www.rainews.it/dl/rainews/.*' || continue) || echo $u  | grep -qE 'http://www.*.rai..*/dl/RaiTV/programmi/media/*|http://www.*.rai..*/dl/RaiTV/tematiche/.*|http://www.*.rai..*/dl/.*PublishingBlock-.*|http://www.*.rai..*/dl/replaytv/replaytv.html.*|http://.*.rai.it/.*|http://www.rainews.it/dl/rainews/.*' || continue
 
 sane="$(echo "$u" | sed 's/\&/%26/g' | sed 's/\=/%3D/g' | sed 's/\:/%3A/g' | sed 's/\//%2F/g' | sed 's/\?/%3F/g')"

 api="$(wget "http://video.daniil.it/api/rai.php?url=$sane&p=v2" -q -O - | sed '/^\s*$/d')"

 echo "$api" | grep -q \( || continue
 titles=$(echo "$api" | sed -n 1p)
 api=$(echo "$api" | sed '1!d')
 title=$(echo "$titles" | cut -d \  -f 1)

 dlcmd
done


[ "$queue" != "" ] && echo "Downloading videos..." && eval $queue && echo "All downloads completed successfully."
