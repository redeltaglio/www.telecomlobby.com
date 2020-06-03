#!/bin/ksh

OUTPUT="/home/taglio/Work/telecomlobby.com/output/"
WWWOUTPUT="/var/www/htdocs/telecomlobby.com/test/"

rm -rf $WWWOUTPUT*
for html_file in $(ls $OUTPUT)
do
	doas cp $OUTPUT$html_file $WWWOUTPUT
done
./wwwperm.sh
