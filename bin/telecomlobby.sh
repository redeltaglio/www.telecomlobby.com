#!/bin/ksh

# uncomment the following two lines if you have both BSD sed and GNU sed installed
# this script is only tested to work with GNU sed which may have the command gsed
#shopt -s expand_aliases
alias sed=gsed

# move the original text to a temp file that can be progressively modified
temp_file="/tmp/markdown.$$"
cat "$1" > "$temp_file"

# All of this below business is for reference-style links and images
# We need to loop across newlines and not spaces
IFS='
'
refs=$(sed -nr "/^\[.+\]: +/p" "$1")
for ref in $refs
do
    ref_id=$(echo -n "$ref" | sed -nr "s/^\[(.+)\]: .*/\1/p" | tr -d '\n')
    ref_url=$(echo -n "$ref" | sed -nr "s/^\[.+\]: (.+)/\1/p" | cut -d' ' -f1 | tr -d '\n')
    ref_title=$(echo -n "$ref" | sed -nr "s/^\[.+\]: (.+) \"(.+)\"/\2/p" | sed 's@|@!@g' | tr -d '\n')

    # reference-style image using the label
    sed -ri "s|!\[([^]]+)\]\[($ref_id)\]|<img src=\"$ref_url\" title=\"$ref_title\" alt=\"\1\" />|gI" "$temp_file"
    # reference-style link using the label
    sed -ri "s|\[([^]]+)\]\[($ref_id)\]|<a href=\"$ref_url\" title=\"$ref_title\">\1</a>|gI" "$temp_file"

    # implicit reference-style
    sed -ri "s|!\[($ref_id)\]\[\]|<img src=\"$ref_url\" title=\"$ref_title\" alt=\"\1\" />|gI" "$temp_file"
    # implicit reference-style
    sed -ri "s|\[($ref_id)\]\[\]|<a href=\"$ref_url\" title=\"$ref_title\">\1</a>|gI" "$temp_file"
done

# delete the reference lines
sed -ri "/^\[.+\]: +/d" "$temp_file"

# blockquotes
# use grep to find all the nested blockquotes
while grep '^> ' "$temp_file" >/dev/null
do
    sed -nri '
/^$/b blockquote
H
$ b blockquote
b
:blockquote
x
s/(\n+)(> .*)/\1<blockquote>\n\2\n<\/blockquote>/ # wrap the tags in a blockquote
p
' "$temp_file"

    sed -i '1 d' "$temp_file" # cleanup superfluous first line

    # cleanup blank lines and remove subsequent blockquote characters
    sed -ri '
/^> /s/^> (.*)/\1/
' "$temp_file"
done

# Setext-style headers
sed -nri '
# Setext-style headers need to be wrapped around newlines
/^$/ b print
# else, append to holding area
H
$ b print
b
:print
x
/=+$/{
s/\n(.*)\n=+$/\n<h1>\1<\/h1>/
p
b
}
/\-+$/{
s/\n(.*)\n\-+$/\n<h2>\1<\/h2>/
p
b
}
p
' "$temp_file"

sed -i '1 d' "$temp_file" # cleanup superfluous first line

# atx-style headers and other block styles
sed -ri '
/^#+ /s/ #+$// # kill all ending header characters
/^# /s/# ([A-Za-z0-9 ]*)(.*)/<h1 id="\1">\1\2<\/h1>/g # H1
/^#{2} /s/#{2} ([A-Za-z0-9 ]*)(.*)/<h2 id="\1">\1\2<\/h2>/g # H2
/^#{3} /s/#{3} ([A-Za-z0-9 ]*)(.*)/<h3 id="\1">\1\2<\/h3>/g # H3
/^#{4} /s/#{4} ([A-Za-z0-9 ]*)(.*)/<h4 id="\1">\1\2<\/h4>/g # H4
/^#{5} /s/#{5} ([A-Za-z0-9 ]*)(.*)/<h5 id="\1">\1\2<\/h5>/g # H5
/^#{6} /s/#{6} ([A-Za-z0-9 ]*)(.*)/<h6 id="\1">\1\2<\/h6>/g # H6
/^\*\*\*+$/s/\*\*\*+/<hr \/>/ # hr with *
/^---+$/s/---+/<hr \/>/ # hr with -
/^___+$/s/___+/<hr \/>/ # hr with _
' "$temp_file"

# unordered lists
# use grep to find all the nested lists
while grep '^[\*\+\-] ' "$temp_file" >/dev/null
do
sed -nri '
# wrap the list
/^$/b list
# wrap the li tags then add to the hold buffer
# use uli instead of li to avoid collisions when processing nested lists
/^[\*\+\-] /s/[\*\+\-] (.*)/<\/uli>\n<uli>\n\1/
H
$ b list # if at end of file, check for the end of a list
b # else, branch to the end of the script
# this is where a list is checked for the pattern
:list
# exchange the hold space into the pattern space
x
# look for the list items, if there wrap the ul tags
/<uli>/{
s/(.*)/\n<ul>\1\n<\/uli>\n<\/ul>/ # close the ul tags
s/\n<\/uli>// # kill the first superfluous closing tag
p
b
}
p
' "$temp_file"

sed -i '1 d' "$temp_file" # cleanup superfluous first line

# convert to the proper li to avoid collisions with nested lists
sed -i 's/uli>/li>/g' "$temp_file"

# prepare any nested lists
sed -ri '/^[\*\+\-] /s/(.*)/\n\1\n/' "$temp_file"
done

# ordered lists
# use grep to find all the nested lists
while grep -E '^[1-9]+\. ' "$temp_file" >/dev/null
do
sed -nri '
# wrap the list
/^$/b list
# wrap the li tags then add to the hold buffer
# use oli instead of li to avoid collisions when processing nested lists
/^[1-9]+\. /s/[1-9]+\. (.*)/<\/oli>\n<oli>\n\1/
H
$ b list # if at end of file, check for the end of a list
b # else, branch to the end of the script
:list
# exchange the hold space into the pattern space
x
# look for the list items, if there wrap the ol tags
/<oli>/{
s/(.*)/\n<ol>\1\n<\/oli>\n<\/ol>/ # close the ol tags
s/\n<\/oli>// # kill the first superfluous closing tag
p
b
}
p
' "$temp_file"

sed -i '1 d' "$temp_file" # cleanup superfluous first line

# convert list items into proper list items to avoid collisions with nested lists
sed -i 's/oli>/li>/g' "$temp_file"

# prepare any nested lists
sed -ri '/^[1-9]+\. /s/(.*)/\n\1\n/' "$temp_file"
done

# make escaped periods literal
sed -ri '/^[1-9]+\\. /s/([1-9]+)\\. /\1\. /' "$temp_file"


# code blocks
#sed -nri '
# if at end of file, append the current line to the hold buffer and print it
#${
#H
#b code
#}
# wrap the code block on any non code block lines
#/^\t| {4}/!b code
# else, append to the holding buffer and do nothing
#H
#b # else, branch to the end of the script
#:code
# exchange the hold space with the pattern space
#x
# look for the code items, if there wrap the pre-code tags
#/\t| {4}/{
#s/(\t| {4})(.*)/<pre><code>\n\1\2\n<\/code><\/pre>/ # wrap the ending tags
#p
#b
#}
#p
#' "$temp_file"

sed -i '1 d' "$temp_file" # cleanup superfluous first line

# convert html characters inside pre-code tags into printable representations
#sed -ri '
# get inside pre-code tags
#/^<pre><code>/{
#:inside
#n
# if you found the end tags, branch out
#/^<\/code><\/pre>/!{
#s/&/\&amp;/g # ampersand
#s/</\&lt;/g # less than
#s/>/\&gt;/g # greater than
#b inside
#}
#}
#' "$temp_file"

# remove the first tab (or 4 spaces) from the code lines
sed -ri 's/^\t| {4}(.*)/\1/' "$temp_file"

# br tags
sed -ri '
# if an empty line, append it to the next line, then check on whether there is two in a row
/^$/ {
N
N
/^\n{2}/s/(.*)/\n<br \/>\1/
}
' "$temp_file"
# inline styles and special characters
sed -ri '
#s/(\(.*\))/\1\n/g # automatic links
s/\)\)/\)\)\n/g
s/(\)[^\)])/\1\n/g
s/<(.*@.*\..*)>/<a href=\"mailto:\1\">\1<\/a>/g # automatic email address links
# inline code
s/([^\\])``+ *([^ ]*) *``+/\1<code>\2<\/code>/g
s/([^\\])`([^`]*)`/\1<code>\2<\/code>/g
s/!\[(.*)\]\((.*) \"(.*)\"\)/<img alt=\"\1\" src=\"\2\" title=\"\3\" \/>/g # inline image with title
s/!\[(.*)\]\((.*)\)/<img alt=\"\1\" src=\"\2\" \/>/g # inline image without title
s/\[(.*)]\((.*) "(.*)"\)/<a href=\"\2\" title=\"\3\">\1<\/a>/g # inline link with title
# s/\[(.*)]\((.*)\)/<a href=\"\2\">\1<\/a>/g # inline link
# special characters
/&.+;/!s/&/\&amp;/g # ampersand
/<[\/a-zA-Z]/!s/</\&lt;/g# less than bracket
# backslash escapes for literal characters
s/\\\*/\*/g # asterisk
s/\\_/_/g # underscore
s/\\`/`/g # underscore
s/\\#/#/g # pound or hash
s/\\\+/\+/g # plus
s/\\\-/\-/g # minus
s/\\\\/\\/g # backslash
' "$temp_file"  
# emphasis and strong emphasis and strikethrough

# s/\*([^\*]+)\*/<em>\1<\/em>/g
# s/([^\\])_([^_]+)_/\1<em>\2<\/em>/g
# s/__([^_]+)__/<strong>\1<\/strong>/g




# paragraphs
sed -nri '
# if an empty line, check the paragraph
/^$/ b para
# else append it to the hold buffer
H
# at end of file, check paragraph
$ b para
# now branch to end of script
b
# this is where a paragraph is checked for the pattern
:para
# return the entire paragraph into the pattern space
x
# look for non block-level elements, if there - print the p tags
/\n<(div|table|pre|p|[ou]l|h[1-6]|[bh]r|blockquote|li)/!{
s/(\n+)(.*)/\1<p>\n\2\n<\/p>/
p
b
}
p
' "$temp_file"

sed -i '1 d' "$temp_file" # cleanup superfluous first line

# cleanup area where P tags have broken nesting
sed -nri '
# if the line looks like like an end tag
/^<\/(div|table|pre|p|[ou]l|h[1-6]|[bh]r|blockquote)>/{
h
# if EOF, print the line
$ {
x
b done
}
# fetch the next line and check on whether or not it is a P tag
n
/^<\/p>/{
G
b done
}
# else, append the line to the previous line and print them both
H
x
}
:done
p
' "$temp_file"



#Modified by taglio

sed -ri '
/<br/d
s/h3/h1/g
s/<ol>/<ul>/g
s/<\/ol>/<\/ul>/g
/^$/d
' "$temp_file"

sed -nri '/<img.*/{x;n;d;};1h;1!{x;p;};${x;p;}' "$temp_file"
#cat "$temp_file" | sed '1,/<h1 id="External/!d' > "$temp_file"

cat <<EOF > /tmp/header.txt
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<link href='/Css/main.css' rel='stylesheet' type='text/css'>
<link href='/Css/code.css' rel='stylesheet' type='text/css'>
<meta content='text/html; charset=UTF-8' http-equiv='Content-Type' />
<meta name="description" content="Neural control network in Europe derived from nobility strictly connected to child trafficking. Forced labor. Slavery. Gangstalking." />
<link rel="canonical" href="https://telecomlobby.com" />
<head>
    <title>The worldwide neural control network, a network full of violence. Gangstalking.</title>
</head>
<body>
    <h3 style='margin-left: 5px; margin-top: 20px;'>
    <a href='/' id='myname'>Riccardo Giuntoli</a>
    </h3>
    <div id='article'>
EOF
cat <<EOF > /tmp/footer.txt
   <p class='timestamp'>
    Last updated on November 29, 2019
    </p>
</body>
</html>
EOF
cat /tmp/header.txt > /tmp/final
cat "$temp_file"  >> /tmp/final && rm "$temp_file"
cat /tmp/final| sed '1,/<h1 id="External/!d' | sed '/<h1 id="External/d' > /tmp/final2
cat /tmp/footer.txt >> /tmp/final2
perl ~/Bin/markdown.bash/links.pl /tmp/final2 > /tmp/final

sed -nri '
# batch up the entire stream of text until a line break in the action
/^$/b emphasis
H
$ b emphasis
b
:emphasis
x
#s////g
#/(\*\*(.*)\*\*\ \[\[[.*\]\])(\((.*)\))/<a href="\2">\1<\/a>/
s/\*\*([A-Za-z_0-9 \/\-]*)\*\*/<span class="important">\1<\/span>/g
#s/(\[\[([0-9]+)\]\])(\((http[s]?:\/\/.*)\))/<a href=\2 rel="external nofollow">\1<\/a>/g
#s/(href=)\((http[s]?:\/\/.*)\)/\1\"\2\"/g
#s/(\[\[([0-9]+)\]\])http[s]?:\/\/.*/<a href=\"\2\" rel="external nofollow">\1<\/a>/g
s/\*([A-Za-z_0-9 \/\-]*)\*/<em>\1<\/em>/g
#s/\[\[[0-9]+\]\]/<a href="">\1</a>/g

# s/\~\~(.+)\~\~/<strike>\1<\/strike>/g
p
' /tmp/final
cat /tmp/final | sed 1d 
