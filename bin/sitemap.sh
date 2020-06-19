#!/bin/ksh

WWWDIR="/var/www/htdocs/telecomlobby.com"
TEMPLATEDIR="/home/taglio/Work/telecomlobby.com/footer"
ver=$(date "+%Y-%m-%dT%H:%M:%S+02:00")
DOWNLOAD="/var/www/htdocs/telecomlobby.com/Download/"
IMAGES="/var/www/htdocs/telecomlobby.com/Images/"
CC="/var/www/htdocs/telecomlobby.com/RNMnetwork/CC/"
DS="/var/www/htdocs/telecomlobby.com/RNMnetwork/datasheets/"
CMP="/var/www/htdocs/telecomlobby.com/RNMnetwork/complaints/"
DOC="/var/www/htdocs/telecomlobby.com/RNMnetwork/documents/"
LAWS="/var/www/htdocs/telecomlobby.com/RNMnetwork/laws/"
PATENTS="/var/www/htdocs/telecomlobby.com/RNMnetwork/patents/"
TMPSITE=$(mktemp)

cp $WWWDIR/sitemap.template $TMPSITE 

sed -i "s/<p><em>.*<\/em><\/p>/<p><em>V 0.9 alpha - $ver<\/em><\/p>/"  $WWWDIR/index.html
sed -i "s/<p><em>.*<\/em><\/p>/<p><em>V 0.9 alpha - $ver<\/em><\/p>/"  $TEMPLATEDIR/footer.html
sed -i "s/<p><em>.*<\/em><\/p>/<p><em>V 0.9 alpha - $ver<\/em><\/p>/" $TEMPLATEDIR/carcelona_footer.html
sed -i "s/<lastmod>.*<\/lastmod>/<lastmod>$ver<\/lastmod>/g" $TMPSITE

sed -i '$d' $TMPSITE 
#grep -v "</urlset>" $WWWDIR/sitemap.xml > $TMPSITE
#echo "<url>" >> $TMPSITE
for html_file in $(ls $DOWNLOAD)
do
	echo "<url>" >> $TMPSITE
        echo "<loc>http://telecomlobby.com/Download/"$html_file"</loc>" >> $TMPSITE
        echo "<lastmod>"$ver"</lastmod>" >> $TMPSITE
	echo "</url>" >> $TMPSITE
done

for html_file in $(ls $CC)
do
        echo "<url>" >> $TMPSITE
        echo "<loc>http://telecomlobby.com/RNMnetwork/CC/"$html_file"</loc>" >> $TMPSITE
        echo "<lastmod>"$ver"</lastmod>" >> $TMPSITE
        echo "</url>" >> $TMPSITE
done

for html_file in $(ls $DS)
do
        echo "<url>" >> $TMPSITE
        echo "<loc>http://telecomlobby.com/RNMnetwork/datasheets/"$html_file"</loc>" >> $TMPSITE
        echo "<lastmod>"$ver"</lastmod>" >> $TMPSITE
        echo "</url>" >> $TMPSITE
done

for html_file in $(ls $CMP)
do
        echo "<url>" >> $TMPSITE
        echo "<loc>http://telecomlobby.com/RNMnetwork/complaints/"$html_file"</loc>" >> $TMPSITE
        echo "<lastmod>"$ver"</lastmod>" >> $TMPSITE
        echo "</url>" >> $TMPSITE
done

for html_file in $(ls $DOC)
do
        echo "<url>" >> $TMPSITE
        echo "<loc>http://telecomlobby.com/RNMnetwork/documents/"$html_file"</loc>" >> $TMPSITE
        echo "<lastmod>"$ver"</lastmod>" >> $TMPSITE
        echo "</url>" >> $TMPSITE
done

for html_file in $(ls $LAWS)
do
        echo "<url>" >> $TMPSITE
        echo "<loc>http://telecomlobby.com/RNMnetwork/laws/"$html_file"</loc>" >> $TMPSITE
        echo "<lastmod>"$ver"</lastmod>" >> $TMPSITE
        echo "</url>" >> $TMPSITE
done

for html_file in $(ls $PATENTS)
do
        echo "<url>" >> $TMPSITE
        echo "<loc>http://telecomlobby.com/RNMnetwork/patents/"$html_file"</loc>" >> $TMPSITE
        echo "<lastmod>"$ver"</lastmod>" >> $TMPSITE
        echo "</url>" >> $TMPSITE
done


echo "</urlset>" >> $TMPSITE
mv $TMPSITE $WWWDIR/sitemap.xml



