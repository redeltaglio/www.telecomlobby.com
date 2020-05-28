#!/bin/ksh

RGMD="/home/taglio/Work/RNMnetwork/riccardo_giuntoli/"
HEADER="/home/taglio/Work/telecomlobby.com/header/"
FOOTER="/home/taglio/Work/telecomlobby.com/footer/footer.html"
OUTPUT="/home/taglio/Work/telecomlobby.com/output/"
TMPPAGE=$(mktemp)
TMPHTML=$(mktemp)

for markdown_file in $(ls $RGMD)
do
	namemd=$(echo $markdown_file | cut -d "." -f1)
	for html_file in $(ls $HEADER)
	do
		namehtml=$(echo $html_file | cut -d "." -f1)
		if [ "$namemd" = "$namehtml" ]; then
			cat $HEADER$html_file > $TMPPAGE
			cat $RGMD$markdown_file | markdown > $TMPHTML
			#sed manipulation
			cat $TMPHTML | sed -nr '/[Ee]xternal [Ll]inks/q;p' > $TMPHTML
			cat $TMPHTML | sed -e 's/<h3>/<h1>/' -e 's/<\/h3>/<\/h1>/' > $TMPHTML
			cat $TMPHTML >> $TMPPAGE
			cat $FOOTER >> $TMPPAGE
			cp $TMPPAGE $OUTPUT$namemd".htm"
		fi
	done
done

rm $TMPPAGE
rm $TMPHTML
