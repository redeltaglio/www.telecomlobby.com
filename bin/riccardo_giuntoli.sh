#!/bin/ksh

###NOTES
#awk -v old="$ATEXT" -v new="$ATEXTNEU" 'p=index($0, old) {print substr($0, 1, p-1) new substr($0, p+length(old)) }' $OUTPUT$html_file
#https://stackoverflow.com/questions/29613304/is-it-possible-to-escape-regex-metacharacters-reliably-with-sed
#
#
#

RGMD="/home/taglio/Work/RNMnetwork/riccardo_giuntoli/"
HEADER="/home/taglio/Work/telecomlobby.com/header/"
FOOTER="/home/taglio/Work/telecomlobby.com/footer/footer.html"
OUTPUT="/home/taglio/Work/telecomlobby.com/output/"
TMPPAGE=$(mktemp)
TMPHTML=$(mktemp)
OUTPUT="/home/taglio/Work/telecomlobby.com/output/"
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
			cat $TMPHTML >> $TMPPAGE
			cat $FOOTER >> $TMPPAGE
			cp $TMPPAGE $OUTPUT$namemd".htm"
		fi
	done
done

unset html_file

for html_file in $(ls $OUTPUT)
do
	LINENUM=$(cat $OUTPUT$html_file | grep "<strong>" | wc -l)
	while [[ $i -le $LINENUM ]]; do 
		ATEXT=$(cat $OUTPUT$html_file | grep "<strong>" | head -n $i | tail -n 1)
		STRONG=$(echo $ATEXT | cut -d ">" -f2 | cut -d "<" -f1)
		ATEXTNEU=$(echo $ATEXT | sed -r -e 's/(\[..\])/'"$STRONG"'/' | cut -d \> -f3)
		ATEXTNEU=$ATEXTNEU">"$(echo $ATEXT | sed -r -e 's/(\[..\])/'"$STRONG"'/' | cut -d \> -f4) 
		ATEXTNEU=$ATEXTNEU">"$(echo $ATEXT | sed -r -e 's/(\[..\])/'"$STRONG"'/' | cut -d \> -f5)
		ATEXTNEU=$(echo $ATEXTNEU | sed 's/<\/p/<\/p>/')
		i=$i+1
		#echo $ATEXTNEU
		#ATEXTESCAPED=$(echo $ATEXT | gsed 's/[^^]/[&]/g; s/\^/\\^/g')
		#ATEXTNEUESCAPED=$(echo $ATEXTNEU | gsed 's/[^^]/[&]/g; s/\^/\\^/g')
		#echo $ATEXT
		#echo $ATEXTNEU
		perl -s -0777 -pe 's/\Q$from\E/$to/' $OUTPUT$html_file -from="$ATEXT" -to="$ATEXTNEU" 
		#sed -i "s/${ATEXTESCAPED}/${ATEXTNEUESCAPED}/g" $OUTPUT$html_file
		ATEXT=""
		ATEXTNEU=""
	done
	i=1
done 

rm $TMPPAGE
rm $TMPHTML

