#!/bin/ksh

###NOTES
#awk -v old="$ATEXT" -v new="$ATEXTNEU" 'p=index($0, old) {print substr($0, 1, p-1) new substr($0, p+length(old)) }' $OUTPUT$html_file
#https://stackoverflow.com/questions/29613304/is-it-possible-to-escape-regex-metacharacters-reliably-with-sed
#
#
###

if [[ $# -eq 0 ]];then
	print "No Arguments"
	exit
fi

RGMD="/home/taglio/Work/RNMnetwork/$1/"
HEADER="/home/taglio/Work/telecomlobby.com/header/"
FOOTER="/home/taglio/Work/telecomlobby.com/footer/footer.html"
OUTPUT="/home/taglio/Work/telecomlobby.com/output/"
TMPPAGE=$(mktemp)
TMPHTML=$(mktemp)
OUTPUT="/home/taglio/Work/telecomlobby.com/output/"
BIN="/home/taglio/Work/telecomlobby.com/bin/"
integer LINENUM
integer i=1
ATEXT=""
ATEXTESCAPED=""
ATEXTNEU=""
ATEXTNEUESCAPED=""
STRONG=""

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
			cat $TMPHTML | sed -e 's/<p><img/<img/' -e 's/\/><\/p>/\/>/' > $TMPHTML
			cat $TMPHTML | sed -e 's/<p><em>/<p><span class="important">/' -e 's/<\/em><\/p>/<\/span><\/p>/' > $TMPHTML
			cat $TMPHTML | sed -r 's/<\/em>[.]<\/p>/<\/span><\/p>/' > $TMPHTML
			cat $TMPHTML | sed -r 's/<\/em> <\/p>/<\/span><\/p>/' > $TMPHTML
			cat $TMPHTML | gsed -E 's/<strong>/\n<strong>/g' > $TMPHTML
			cat $TMPHTML | sed -r 's/~~(.*)~~/<span class="strike">\1<\/span>/g' > $TMPHTML
			cat $TMPHTML | grep -v  \<hr > $TMPHTML
			cat $TMPHTML | sed -r -e 's/<p[>|>\n]<code>/<code>/' -e 's/<\/code[>|>\n]<\/p>/<\/code>/' > $TMPHTML
			cat $TMPHTML | sed -r -e 's/<p>```/<code>/' -e 's/```<\/p>/<\/code>/' > $TMPHTML
			cat $TMPHTML | gsed  -e '/^<code>/,/^<\/code>/ {s/<[^>]*>//g}' | sed '/^$/d' | gsed '1 i\<code>' | gsed -e "\$a<\/code>" > $TMPHTML
			cat $TMPHTML >> $TMPPAGE
			cat $FOOTER >> $TMPPAGE
			cp $TMPPAGE $OUTPUT$namemd".htm"
		fi
	done
done

unset html_file

for html_file in $(ls $OUTPUT)
do
	perl ./links.pl $OUTPUT$html_file > /tmp/$html_file
	cp /tmp/$html_file $OUTPUT$html_file
done 

rm $TMPPAGE
rm $TMPHTML

