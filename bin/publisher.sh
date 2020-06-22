#!/bin/ksh

###NOTES
#awk -v old="$ATEXT" -v new="$ATEXTNEU" 'p=index($0, old) {print substr($0, 1, p-1) new substr($0, p+length(old)) }' $OUTPUT$html_file
#https://stackoverflow.com/questions/29613304/is-it-possible-to-escape-regex-metacharacters-reliably-with-sed
#
#
###

function imgsubdomain {
        subdomain=$(echo $1 | sed "s/[^a-zA-Z']//g")
        echo $subdomain
}


if [[ $# -eq 0 ]];then
	print "No Arguments"
	exit
fi

RGMD="/home/taglio/Work/RNMnetwork/$1/"
HEADER="/home/taglio/Work/telecomlobby.com/header/"
FOOTER="/home/taglio/Work/telecomlobby.com/footer/footer.html"
FOOTER_CARCELONA="/home/taglio/Work/telecomlobby.com/footer/carcelona_footer.html"
FOOTER_EVIDENCES="/home/taglio/Work/telecomlobby.com/footer/overwhelming_evidences_footer.html"
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
WWWDIR="/var/www/htdocs/telecomlobby.com/"
SPIDERDIR="/var/www/htdocs/unspider.telecomlobby.com"
WWWOUTPUT="/var/www/htdocs/telecomlobby.com/test/"


rm -rf $OUTPUT*

for markdown_file in $(ls $RGMD)
do
	namemd=$(echo $markdown_file | cut -d "." -f1)
	for html_file in $(ls $HEADER)
	do
		namehtml=$(echo $html_file | cut -d "." -f1)
		if [ "$namemd" = "$namehtml" ]; then
			cat $HEADER$html_file > $TMPPAGE
			cat $RGMD$markdown_file | markdown > $TMPHTML

			#sed delete
			sed -nri '/[Ee]xternal [Ll]inks/q;p' $TMPHTML
			sed -ir '/<p>```<\/p>/d' $TMPHTML
			sed  -i '/<hr/d' $TMPHTML

			#sed change
			sed -i -e 's/<h3>/<h2>/' -e 's/<\/h3>/<\/h2>/' $TMPHTML
			sed -i -r 's/~~(.*)~~/<span class="strike">\1<\/span>/' $TMPHTML
			gsed -i 's/<strong>/\n<strong>/g' $TMPHTML
			sed -i 's/^<p>```/<code>/g' $TMPHTML
			sed -i 's/```<\/p>$/<\/code>/g' $TMPHTML
			sed -i 's/^<p><code>$/<code>/g' $TMPHTML
			sed -i 's/^<\/code><\/p>$/<\/code>/g' $TMPHTML
			sed -i -e 's/^<p><img/<img/' -e 's/\/><\/p>$/\/>/' $TMPHTML
			#sed strip
			
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
			test=$(grep "^...*<em>" $TMPHTML)
                        while [[ $test != ""  ]] do
                                sed -ri 's/^(...*)<em>/\1<span class="important">/' $TMPHTML
                                test=$(grep "^...*<em>" $TMPHTML)
                        done
                        test=$(grep "^...*</em>" $TMPHTML)
                        while [[ $test != ""  ]] do
                                sed -ri 's/^(...*)<\/em>/\1<\/span> /' $TMPHTML
                                test=$(grep "^...*</em>" $TMPHTML)
                        done
			
			#little specific adjunt if tor.md
			if [ $namemd == "openbsd_tor_privoxy" ]; then
				gsed -i '/alt=\"torbsd proyect\"/,+1 d' $TMPHTML
				sed -ri 's/\}<\/span>/\}<\/span><\/p>/' $TMPHTML
				sed -ri 's/Ok, the cooking/<p>Ok, the cooking/' $TMPHTML
				sed -ri 's/Now we/<p>Now we/' $TMPHTML
				sed -ri 's/settings<\/span>/settings<\/span><\/p>/' $TMPHTML
				sed -ri 's/Ok simply/<p>Ok simply/' $TMPHTML
				sed -ri 's/command\:/command\:<\/p>/' $TMPHTML
				sed -ri 's/Arguments<span class="important">against<\/span>systemd/Arguments_against_systemd/' $TMPHTML
				sed -ri 's/Now create/<p>Now create/' $TMPHTML
				sed -ri 's/with :/with :<\/p>/' $TMPHTML
				sed -ri 's/<\/p>  and\:<\/p>/and\:<\/p>/' $TMPHTML
				sed -ri 's/<p><p>/<p>/' $TMPHTML
				sed -ri 's/<\/p><\/p>/<\/p>/' $TMPHTML
				sed -ri 's/-t<\/p>/-t table/' $TMPHTML
				sed -ri 's/<p>-T/-T/' $TMPHTML
			fi
			cat $TMPHTML >> $TMPPAGE
			if [ $namemd == "catalan_neural_applications" ]; then
				cat $FOOTER_CARCELONA >> $TMPPAGE
			elif [ $namemd == "overwhelming_evidences" ]; then
				cat $FOOTER_EVIDENCES >> $TMPPAGE
			else
				cat $FOOTER >> $TMPPAGE
			fi
			cp $TMPPAGE $OUTPUT$namemd".htm"
		fi
	done
done

unset html_file

if [[ $2 == "output" ]]; then
	rm -rf $WWWOUTPUT*
fi

for html_file in $(ls $OUTPUT)
do
	perl ./links.pl $OUTPUT$html_file > /tmp/$html_file
	cp /tmp/$html_file $OUTPUT$html_file
	if [[ $2 == "www" ]]; then
		case $1 in 
			"riccardo_giuntoli")
				imgsubdomain $1
				mv /tmp/$html_file $WWWDIR$1/$html_file ;;
			"RNMnetwork")
				if [[ $html_file == "sexual_harassment.htm"  ]]; then
					mv /tmp/$html_file $SPIDERDIR/$html_file  
				else
					mv /tmp/$html_file $WWWDIR$1/$html_file 
				fi ;;
			"RNMnetwork/considerations")
				mv /tmp/$html_file $WWWDIR$1/$html_file ;;
			"RNMnetwork/ES")
				mv /tmp/$html_file $WWWDIR$1/$html_file ;;
			"opensource_guides")
				mv /tmp/$html_file $WWWDIR$1/$html_file ;;
			"RNMnetwork/ES/gangstalking")
				mv /tmp/$html_file $WWWDIR$1/$html_file ;;
			"RNMnetwork/ES/get_access")
				mv /tmp/$html_file $WWWDIR$1/$html_file ;;
			"RNMnetwork/technomafia")
				mv /tmp/$html_file $WWWDIR$1/$html_file ;;
			"RNMnetwork/technomafia/sect")
                                mv /tmp/$html_file $WWWDIR$1/$html_file ;;
			"radioham")
                                mv /tmp/$html_file $WWWDIR$1/$html_file ;;
			"RNMnetwork/technomafia/crimes_deaths_laws_health")
				mv /tmp/$html_file $WWWDIR$1/$html_file ;;
			"RNMnetwork/electrosmog")
                                mv /tmp/$html_file $WWWDIR$1/$html_file ;;
		esac
	elif [[ $2 == "output" ]]; then
		doas cp $OUTPUT$html_file $WWWOUTPUT
	fi
done 

#if [[ $2 != "" ]]; then
#	./wwwperm.sh
#fi

rm $TMPPAGE
rm $TMPHTML


