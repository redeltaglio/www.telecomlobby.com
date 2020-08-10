#!/usr/bin/perl
#
# epub2text by superkuh
# required binaries: unzip, html2text.
#
# Don't use this if you don't have to, it's a shitty hack.
# The program 'Calibre' has a cli interface called 'ebook-convert'
# that is much better.
#
# It extracts the zip, looks in the temp and temp/OEBPS dirs
# for *.ncx, which is the table of contents. Ignoring the
# xml structure I rip out the contents in order with a
# regex. Then I check to see if the filename has OEBPS
# prefixed, if it does I removed it, then I pick the
# appropriate dir myself and cat the xhtml files together.
# html2text does the heavy lifting on the generated file
# turning it into text, but I remove remaining <?xml ..>
# tags by hand with another greedy regex while printing
# to STDOUT.

use strict;
use warnings;

my $tmpdir = '/tmp/epub2text';
my $OEBPSdir = 0;
my $html2text = 'html2text -width 140';
`rm -rf $tmpdir`;
my $filename = $ARGV[0];

if ($ARGV[0] =~ /(-h|--h|-help|--help)/i) {
	help();
}

if (-e $filename) {
	mkdir($tmpdir, 0777) || die "dir creation $tmpdir failed: $!";
	#copy("$filename","$tmpdir/epub.zip") or die "Copy failed: $!";
	system "cp", "$filename", "$tmpdir/epub.zip";
	`unzip $tmpdir/epub.zip -d $tmpdir`;
	if (-d "$tmpdir/OEBPS") {	
		#$tmpdir = "$tmpdir/OEBPS";
		$OEBPSdir = "$tmpdir/OEBPS";
	} elsif (-d "$tmpdir/OPS") {	
		$OEBPSdir = "$tmpdir/OPS";
	}
	
	my $tocfile;
	my $ncxfile = <$tmpdir/*.ncx>; 
	my $ncxfile_OEBPSdir = <$OEBPSdir/*.ncx>;
	if ($ncxfile) {
		$tocfile = $ncxfile;
	} else {
		$tocfile = $ncxfile_OEBPSdir;
	}

	# FUCK IT, We'll do it LIVE.
	my @files;
	open(TOC, "<$tocfile") or die "Can't open file:$tocfile\n$!";
	while (my $line = <TOC>) {
		$line =~ m#<content src=\"(.+)\"#;
		my $filename = $1;	
		$filename =~ s/#(.+)$// if $filename;
		push(@files, $filename) if $filename;
	}

	my @unique;
	# reusing something from my nowplaying.pl music stats script.
	@files = removesubsequentdupes(@files);
	sub removesubsequentdupes {
		my @played = @_;
		my @unique;
		my $previoustrack = "";
		foreach my $track (@played) {
			if ($track eq $previoustrack) {
				next;
			} else {
				push(@unique, $track);
			}
			$previoustrack = $track;
		}
		return @unique;
	}

	foreach my $filename (@files) {
		$filename =~ s/OEBPS\///;
		print "file: $filename\n";

		if ($OEBPSdir) {
			`cat \"$OEBPSdir/$filename\" >> $tmpdir/epub.html`;
		} else {
			`cat \"$tmpdir/$filename\" >> $tmpdir/epub.html`;
		}
	}

	`$html2text $tmpdir/epub.html > $tmpdir/epub.txt`;
	open(TXT, "<$tmpdir/epub.txt") or die "cannot open \$tmpdir/epub.txt\n$!";
	while (<TXT>) { s/<\?xml.+>//; print; }


	$tmpdir =~ s#/OEBPS##;
	#print "\ntmpdir: $tmpdir\n";
	#rmtree($tmpdir);

} else {
	help();
}


sub help {
	print "\nepub2text, by superkuh\n";
	print "$0 filename.epub\n";
	print "$0 /path/to/filename.epub\n";
	print "$0 filename\\ with\\ spaces.epub\n";
	die "\n";
}

## what I used to do
# mkdir ...
# cp $filepath /tmp/epub.zip
# unp /tmp/epub.zip
# cat *.htm > epub.htm
# html2text /tmp/epub.htm > /tmp/epub.txt
# cat /tmp/epub.txt | perl -e 'while (<>) { s/<\?xml.+>//; print FILEOUT; }' > whatever.txt

