#!/usr/bin/perl
#################################
# --==Oldschool Music Player==--
#
# Coded by Perforin | dark-codez
#
#       www.dark-codez.org
#
# Join the dark side of coding!
#################################

my $version = 2.99;

use Win32::MediaPlayer;
use Getopt::Long;
use strict; use warnings;
$|=1;

my $default_played_filename = 'played.txt';
my $played_filename = $default_played_filename;
my $volume = 100;
my $all_in_dir;

GetOptions(
	'playedfile|file=s' => \$played_filename, # let user override
	'last|history!' => \&show_last_played,
	'volume=i' => \$volume,
	'directory|folder|alldir|allindir=s' => \$all_in_dir,
	'help|usage!' => \&usage,
	'gui' => \&loadGui,
);

defined($volume) && $volume =~ /^\s*\d+\s*$/ &&
$volume >= 0 && $volume <= 100 or
	die "Invalid volume; must be a number between 0 and 100.\n";

print <<EOF;

 +-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+
 |O|l|d|s|c|h|o|o|l| |P|l|a|y|e|r|
 +-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+

 BE OLDSCHOOL! USE OLSCHOOL PLAYER


 AND FEEL THE SOUND OF YOUR BLACK BOX!


EOF

open PLAYED,'>',$played_filename or
	die "Can't open $played_filename for writing - $!\n";
# make sure writes to PLAYED autoflush:
{ my $oldfh = select STDERR; $|=1; select $oldfh; }

if ( $all_in_dir )
{
	chdir $all_in_dir or die "chdir $all_in_dir - $!\n";
	play_media_file($_)
		for <*.mp3>,<*.wma>,<*.wav>,<*.midi>;
}
else
{
	@ARGV or usage();
	play_media_file($_)
		for @ARGV;
}

END { close PLAYED; }

sub usage
{
exit print <<EOF;

 +-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+
 |O|l|d|s|c|h|o|o|l| |P|l|a|y|e|r|
 +-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+


 +-+-+-+-+-+-+SyNtaX+-+-+-+-+-+-+

 Usage:

   Play specific media files:
     $0 song1.mp3 song2.mp3

   Play all media files in a directory:
     $0 -all C:\\songs

   List song(s) played last time:
     $0 -last

   Display usage statement:
     $0 -help

 Options:

   Set volume:
     -volume N 
   N must be a number in range 1 .. 100.
   Default is 100.

   Set 'last played songs' file:
     -played FILE
   default is "$default_played_filename"

 +-+-+-+-+-+-+SyNtaX+-+-+-+-+-+-+
EOF
}

sub show_last_played
{
	open PLAYED,'<',$played_filename or
		die "Can't open $played_filename for reading - $!\n";
	print "\n", <PLAYED>;
	close PLAYED;
	exit;
}

sub play_media_file
{
	eval{
	my $media_file = shift;

	my $winmm = new Win32::MediaPlayer;
	my $loaded = $winmm->load($media_file);
	$loaded eq '1' or
		die "Error loading file '$media_file' - $loaded\n";
	$winmm->play;
	$winmm->volume($volume);
	$winmm->seek('00:00');

	print "PLAYED $media_file\n";
	print PLAYED "$media_file\n";

	print " Oldschool Player plays: $media_file\n\n";
	printf " Total Length: %7s\n", $winmm->length(1);
	while ( $winmm->pos() < $winmm->length() )
	{
		printf " Now Position: %7s\r", $winmm->pos(1);
	}
	$winmm->close;
	print " \n\n\n Track finished! \n\n\n";
	};
	$@ and warn $@;
}

sub loadGui{
	my $t = `perl Testing.pl` ;
	print $t;
}