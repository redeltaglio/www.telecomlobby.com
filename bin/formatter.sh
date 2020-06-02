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
test=""

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
			sed -nri '/[Ee]xternal [Ll]inks/q;p' $TMPHTML 
			sed -i -e 's/<h3>/<h1>/' -e 's/<\/h3>/<\/h1>/' $TMPHTML
			sed -i -e 's/<p><img/<img/' -e 's/\/><\/p>/\/>/' $TMPHTML
			sed -i -e 's/<p><img/<img/' -e 's/\/><\/p>/\/>/' $TMPHTML
			sed -i -e 's/<em>/<span class="important">/' -e 's/<\/em>/<\/span>/' $TMPHTML
			gsed -i 's/<strong>/\n<strong>/' $TMPHTML
			sed -i -r 's/~~(.*)~~/<span class="strike">\1<\/span>/' $TMPHTML
			sed  -i '/<hr/d' $TMPHTML
			sed -i -e 's/<p[>|>\n]<code>/<code>/' -e 's/<\/code[>|>\n]<\/p>/<\/code>/' $TMPHTML
			sed -i -e 's/<p>```/<code>/' -e 's/```<\/p>/<\/code>/' $TMPHTML
			gsed  -i -e '/^<code>/,/^<\/code>/{/^<code>/!{/^<\/code>/!s/<[^>]*>//g;/^$/d}}' $TMPHTML
			gsed  -i -e '/^<blockquote>/,/^<\/blockquote>/{/^<blockquote>/!{/^<\/blockquote>/!s/<[^>]*>//g;}}' $TMPHTML
			sed  -i -e 's/<li><p>/<li>/' -e 's/<\/p><\/li>/<\/li>/' $TMPHTML
			test=$(grep "^...*<code>" $TMPHTML)
			while [[ $test != ""  ]] do
				sed -ri 's/^(...*)<code>/\1<span class="coding">/' $TMPHTML
				test=$(grep "^...*<code>" $TMPHTML)
			done
			test=$(grep "^...*</code>" $TMPHTML)
			while [[ $test != ""  ]] do
                                sed -ri 's/^(...*)<\/code>/\1<\/span> /' $TMPHTML
                                test=$(grep "^...*</code>" $TMPHTML)
                        done
			test=""
			i=1
			while [[ i -le 4 ]] do
				if [[ i -eq 1 ]]; then
					gsed -i '0,/<code><\/p>/s//<\/code>/' $TMPHTML
				elif [[ i -eq 2 ]]; then
					gsed -i '0,/<code><\/p>/s//<code>/' $TMPHTML
				elif [[ i -eq 3 ]]; then
                                        gsed -i '0,/<code><\/p>/s//<\/code>/' $TMPHTML
                                elif [[ i -eq 4 ]]; then
                                        gsed -i '0,/<code><\/p>/s//<code>/' $TMPHTML
				fi
				i=$i+1
			done
			#little specific adjunt if tor.md
			if [ $namemd == "tor" ]; then
				gsed -i '/alt=\"torbsd proyect\"/,+1 d' $TMPHTML
				sed -ri 's/\}<\/span>/\}<\/span><\/p>/' $TMPHTML
				sed -ri 's/Ok, the cooking/<p>Ok, the cooking/' $TMPHTML
				sed -ri 's/Now we/<p>Now we/' $TMPHTML
				sed -ri 's/settings<\/span>/settings<\/span><\/p>/' $TMPHTML
				sed -ri 's/Ok simply/<p>Ok simply/' $TMPHTML
				sed -ri 's/command\:/command\:<\/p>/' $TMPHTML
				sed -ri 's/Arguments<span class="important">against<\/span>systemd/Arguments_against_systemd/' $TMPHTML
				sed -ri 's/Now create/<p>Now create/' $TMPHTML
				sed -ri 's/with \:/with \:<\/p>/' $TMPHTML
				sed -ri 's/<\/p>  and\:<\/p>/and\:<\/p>/' $TMPHTML
			fi
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


