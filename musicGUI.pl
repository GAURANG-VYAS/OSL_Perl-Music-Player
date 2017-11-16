#!/usr/local/bin/perl
# Mirrors
use Tk;
use Tk::FileSelect;
use Win32::MediaPlayer;
use File::Basename;
use Image::Base::Tk::Photo;
use Tk::Png;
use IO::Async::Timer::Periodic;
use IO::Async::Loop;
# use Win32::MultiMedia;
# use Tk::EntryDialog;


# Main Window
$mw = new MainWindow;
$mw->geometry("600x600");


@currplaylist = ();
my $load_playlist = $mw -> Button(-text => "Load Playlist", -font=>"{Comic Sans MS} 10",-background=>'white', -relief=>'solid',-command => \&loadPlay)->pack(-side=>'left', -anchor=> 'ne', -padx => 5, -pady => 10);

my $new_playlist = $mw -> Button(-text => "New Playlist", -font=>"{Comic Sans MS} 10",-relief=>'solid',-command => \&createPlay,-background=>'white')->pack(-side=>'right', -anchor=>'nw',-padx => 5,-pady => 10);

my $previmg = $mw->Photo(-format=> 'png',-file => "images/previous.png");
my $nextimg = $mw->Photo(-format=> 'png',-file => "images/next.png");
my $playpauseimg = $mw->Photo(-format=> 'png',-file => "images/play_pause.png");
my $exitimg = $mw->Photo(-format=> 'png',-file => "images/exit.png");

$canv = $mw -> Canvas(-width=>300, -height=>300, -background=> 'white') -> pack(-pady =>10);
my $img1 = $canv->Photo (-file => 'E:\SEM 7\Perl Music Player\images\music1.png', -format=>'png');
my $img2 = $canv->Photo (-file => 'E:\SEM 7\Perl Music Player\images\music2.png', -format=>'png');
my $img3 = $canv->Photo (-file => 'E:\SEM 7\Perl Music Player\images\music3.png', -format=>'png');
my $img4 = $canv->Photo (-file => 'E:\SEM 7\Perl Music Player\images\music4.png', -format=>'png');
@imagarray = ($img1,$img2,$img3,$img4);	
$canv->createImage(0,0, -image=>$img1);	


$imno = 0;
$menubar = $mw->Frame(-relief=>"solid",
                        -borderwidth=>2);
$filebutton = $menubar->Menubutton(-text=>"Select Song",
                                   -font=>"{Comic Sans MS} 10",-background=>'white');

#my $sel_btn = $mw -> Button(-text => "Select Song", -font=>"{Comic Sans MS} 10")->pack(-anchor => 'center',-padx => 10,-pady => 10);
my $exit_btn = $mw -> Button(-text => "Exit", -font=>"{Comic Sans MS} 10", -relief=>'solid',-background=>"maroon",-image=> $exitimg,-command=>\&exitProc)->pack(-side => 'bottom', -expand=>1, -fill=>x, -padx => 5,-pady => 5);
my $prev_btn = $mw -> Button( -font=>"{Comic Sans MS} 10",-image=>$previmg, -relief=>'solid',-background=>"black")->pack(-side => 'left',-padx => 5,-pady => 5);

my $next_btn = $mw -> Button(-font=>"{Comic Sans MS} 10",-image=>$nextimg, -relief=>'solid',-background=>"black")->pack(-side => 'right',-padx => 5,-pady => 5);
my $play_pause = $mw -> Button(-font=>"{Comic Sans MS} 10", -image=>$playpauseimg,-relief=>'solid',-command => \&playSong, -background=>"black")->pack(-anchor => 'center',-padx => 5,-pady => 5);

$currFileSelected = 'Currently Selected ....'; 
$time = 'Playing Nothing';
$song_name = $mw -> Text(-font=>"{Comic Sans MS} 10 ", -foreground=>'blue',-height=>2) ->pack(-side=>'bottom',-anchor => 'center',-padx => 5,-pady => 5,-fill=>'x');
$song_name->tagConfigure('center',-justify=>'center');
$song_name->insert('end',$currFileSelected);
$time_elap = $mw -> Text(-font=>"{Comic Sans MS} 10 ", -foreground=>'green',-height=>2) ->pack(-side=>'bottom',-anchor => 'center',-padx => 5,-pady => 5);
$time_elap->tagConfigure('center',-justify=>'center');
$time_elap->insert('end',$time);

$filemenu = $filebutton->Menu();

$filebutton->configure(-menu=>$filemenu);

$filemenu->command(-command => \&open_choice,
                   -label => "Open...");

$filemenu->separator();


$filebutton->pack(-side=>"left");

$menubar->pack(-side=>"top");


$file_dialog = $mw->FileSelect(-directory => ".");
$file_dialog_multi = $mw->FileSelect(-directory => ".", -selectmode => 'multiple');

$isPlaying = 0;
$isPause  = 0;

# $mw->repeat(2000,\&changeimage);

# my $loop = IO::Async::Loop->new;
# 	my $timer = IO::Async::Timer::Periodic->new(
#     interval => 2,
#     on_tick => sub {
#     	if( $imno > 3){
# 			$imno =0;
# 			$canv->createImage(0,0, -image=>$imgarray[$imno]);
# 			$imno = $imno +1;
# 			print "Changing Im to ".$imno."\n";
# 		}
# 	}
#  );

#  $timer->start;
#  $loop->add( $timer );
#  $loop->run;

MainLoop;




sub open_choice {
    clear();
    
    





    $isPlaying = 0;
    my $types = [
     ['MP 3',      '.mp3' ],
     ['Wave File',       '.wav' ],
     ['MA 4',   '.ma4' ],
     ['Ogg Vorbis',        'ogg'  ]
     ];
 	$filename = $file_dialog->getOpenFile(-filetypes => $types);
    if ($filename ne "" ) {
        $currFileSelected = $filename;

        ($name,$path,$suffix) = fileparse($filename);
    	$name = fileparse($filename);
    	$basename = basename($filename);
    	$dirname  = dirname($filename);

        $currText = 'Currently Seleted => '.$name;
        $song_name->delete('1.0','end');
        $song_name->insert('1.0',$currText);
        
    }
}

sub playSong {
	if(($isPlaying == 1) && ($isPause==1)){
		print "Resuming Song\n";
		resumeSong();
		$isPause = 0;
		return;
	}
	elsif(($isPlaying == 1) && ($isPause==0))
		 {
		 	print "Pausing Song\n";
		 	$isPause = 1;
		 	$winmm->pause;
		 	$time = 'Paused';
    		$time_elap->delete('1.0','end');
    		$time_elap->insert('1.0',$time);
		 	return;
		 }

	if($currFileSelected eq 'Currently Selected ....'){
		return;
	}
	
	print "Playing Song for the first Time => ".$currFileSelected."\n";
	$time = 'Playing ....';
    $time_elap->delete('1.0','end');
    $time_elap->insert('1.0',$time);

	if(defined $winmm)
	{
		$winmm->close;
	}
	$winmm = new Win32::MediaPlayer;  # new an object
	$winmm->load($currFileSelected);        # Load music file disk, or an URL
    $winmm->play;                     # Play the music
    $winmm->volume(100);              # Set volume after playing
    $winmm->seek('00:00');            # seek to
    $isPlaying =1;
   
}

sub resumeSong
{
	print "In Resume";
	$winmm->resume;
	$time = 'Playing ....';
    $time_elap->delete('1.0','end');
    $time_elap->insert('1.0',$time);
}

sub exitProc{
	exit;
}

sub createPlay
{
	# my $entryDialog = $mw ->EntryDialog (-title => 'Enter Playlist Name');
	my $timeep = time();
	# $defname = 'playlist'.$timeep;
	
	# $entryDialog->configure(-textlabel => 'Enter Here ');
	# $entryDialog -> configure(-defaultentry => $defname);
	# my $resp = $entryDialog->WaitForInput;
	# print "$resp\n";
	

	my $file = 'playlist'.$timeep.'.txt';
	open (DATA,'>>tempdata/'.$file);

	my $types = [
     ['MP 3',      '.mp3' ],
     ['Wave File',       '.wav' ],
     ['MA 4',   '.ma4' ],
     ['Ogg Vorbis',        'ogg'  ]
     ];

	my @songs = $file_dialog_multi->getOpenFile(-filetypes => $types, -multiple => 10);
	foreach my $song (@songs) {
		print DATA $song."\n";
	}
	close(DATA);

}

sub loadPlay {

	my $fileDia = $mw->FileSelect(-directory=>'E:\SEM 7\Perl Music Player\tempdata');	
	my $play = $fileDia->getOpenFile(-filetypes => $types,-initialdir=>'E:\SEM 7\Perl Music Player\tempdata');
	# print $play;
	open(SONGLIST,'<'.$play) or die("Could not open file");
	clear();
	foreach $line(<SONGLIST>) {
		chomp $line;
		# print $line."\n";
		push(@currplaylist,$line);
	}
	close(SONGLIST);
	my $cmd = 'perl musicPlayer.pl ';
	print "\n";
	foreach(@currplaylist)
	{
		
		$currFileSelected = shift(@currplaylist);
		$cmd = $cmd.'"'.$currFileSelected.'" ';
		# print "Playing from Playlist -> ".$currFileSelected."\n";
		# # playSong();
	}
	print $cmd;
} 

sub clear{
	while(@currplaylist)
	{
		pop(@currplaylist);
	}
}

sub changeimage
{
	
		if( $imno > 3){
			$imno =0;
		$canv->createImage(0,0, -image=>$imgarray[$imno]);
		$imno = $imno +1;
		print "Changing Im to ".$imno."\n";
	}
}