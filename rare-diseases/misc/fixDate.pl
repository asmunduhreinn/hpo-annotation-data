#!/usr/bin/perl -w
use strict;
use IO::File;

### Fix bad date format
### For this test version, write fixed files to new directory called newFiles

### 1) Make new directory if not exists
my $newdir = "newFiles";
unless (-d $newdir){
  mkdir $newdir or die "$!";
}

### 2) Read all annotation files from old dir
my $olddir = "annotated";
my $dh;
opendir($dh,$olddir) or die "$!";
my @files = grep { m/\.tab$/ } readdir($dh);
closedir($dh);

### 3) Fix date in each file

my $count = 0;

for my $f (@files) {
  my $fh = new IO::File("$olddir/$f") or die "$!";
  processFile($fh,$f,$newdir);
  $count++;
  close($fh);
}


print "Dieses wunderbare Perl-Skript hat $count Files bereinigt!\n";
exit 0; ## Success!

#####################################################################
#####################################################################


## Dies if there is a major problem processing the file.
sub processFile
  {
    my ($fh,$f,$newdir) = @_;
    my @lines;  ## accumulate lines of file here
    my $old_linecount = 0;


    my $header = <$fh>;
    $old_linecount++;
    chomp($header);
    push(@lines,$header);
    my $i = getIndexOfDateField($header);  ## Use header to figure out where date field is
    while (my $oldline = <$fh>) {
      $old_linecount++;
      chomp $oldline;
      my @L = split(m/\t/,$oldline);
      my $date = $L[$i]; ##  (OLD format)
      my ($newdate,$no_date_found) = convertDate($date);
      $L[$i] = $newdate;  ## (NEW format)
      
      ## Note that very old files do not have a column for Assigned By. We could add it in here or do it in 
      ## another step. These files are marked by $no_date_found=TRUE

      ## Some elements (fields) appear to be undefined.
      for (my $j=0;$j<@L;++$j) { $L[$j] = "" unless (defined $L[$j]) }; 
      my $newline = join("\t",@L);
      push(@lines,$newline);
    }
    my $outfh = new IO::File(">$newdir/$f") or die "$!";
    my $new_linecount = 0;
    foreach my $L (@lines) {
      print $outfh "$L\n";
      $new_linecount++;
    }
    $outfh->close();
    if ($old_linecount != $new_linecount) {  ## Sanity check
      print "Line count of old file ($f): $old_linecount, but linecount of new file: $new_linecount\n";
      die "Number of lines did not match\n";
    }
  }


  ###
  ### Convert from any of the many data formats (1999.12.25, Dec 25, 1999, 25.12.1999)
  ### to the desired new format of date.
  ### If no date at all is used in the line, put in today's date.
  ### return ($newdate,$no_date_found)
  ### if $no_date_found == 1, then we have had to add today's date. The calling code should
  ### also add "HPO" to the line (assigned by).


  sub convertDate
    {
      my $newdate = undef;
      my $no_date_found = undef;
      my $date = shift;
      if (!defined($date) or length($date) == 0) { #### i.e., no date provided
	$no_date_found = 1;
	my ($day, $month, $year) = (localtime)[3,4,5];
	#printf("The current date is %04d %02d %02d\n", $year+1900, $month+1, $day);
	my $today = sprintf("%02d.%02d.%04d",$day,$month+1,$year+1900);
	$newdate = $today;
	print "Old date not defined, new date = $newdate\n";
      } elsif ($date =~ m/(\d{4,4})\.(\d{2,2})\.(\d{2,2})/) { #### i.e., old format 1999.12.25
	## Want e.g., 25.12.1999
	my $month = $2;
	my $year = $1;
	my $day = $3;
	$newdate = sprintf("%s.%s.%s",$day,$month, $year); 
	print "OLD: $date -- NEW: $newdate\n";
      } elsif ($date =~ m/\d{2,2}\.\d{2,2}\.\d{4,4}/) { #### Format OK as is, do nothing
	print "OK AS IS: $date\n";
	$newdate = $date;
	## IN the following, we have Dec 25, 1999 
      }  elsif ($date =~ m/(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s+(\d{1,2}),\s+(\d{4,4})/) { 
	## Date such as Dec 25, 1999 found
	my $strmon = $1;
	my $day = $2;
	my $year = $3;
	die "Bad day \"$day\"" unless ($day > 0 && $day < 31);
	die "Bad years \"$year\"" unless ($year > 1999 && $year < 2013);
	my $mon = 0;
	## For some reason, the hash is not working,...
	if ($strmon eq "Jan") { $mon = 1; }
	elsif ($strmon eq "Feb") { $mon = 2; }
	elsif ($strmon eq "Mar") { $mon = 3; }
	elsif ($strmon eq "Apr") { $mon = 4; }
	elsif ($strmon eq "May") { $mon = 5; }
	elsif ($strmon eq "Jun") { $mon = 6; }
	elsif ($strmon eq "Jul") { $mon = 7; }
	elsif ($strmon eq "Aug") { $mon = 8; }
	elsif ($strmon eq "Sep") { $mon = 9; }
	elsif ($strmon eq "Oct") { $mon = 10; }
	elsif ($strmon eq "Nov") { $mon = 11; }
	elsif ($strmon eq "Dec") { $mon = 12; }
	if ($mon < 1) {	  die "Bad month name \"$strmon\""; }
	$newdate = sprintf("%02d\.%02d\.%04d",$day,$mon,$year);
	print "Letter Month: $newdate (OLD=$date)\n";
      }else {
	die "Bad date field: \"$date\"\n";
      }
      return ($newdate,$no_date_found);
    }







  ### This is different depending on the version of Phenote used (argh)
  ### The function expects to get the header line of a Phenote file. This must have
  ##  a field called "Date Created". If not, something sucks bigtime, so just die.
  sub getIndexOfDateField {
    my $header = shift;
    my @H = split(m/\t/,$header);
    for (my $i=0;$i<@H;++$i) {
      my $h = $H[$i];
      return $i if ($h =~ m/Date Created/ && $i>0);
    }
    print "Could not parse header line: \"$header\"\n";
    die;
  }

   sub getIndexOfAssignedByField {
     my $header = shift;
     my @H = split(m/\t/,$header);
     for (my $i=0;$i<@H;++$i) {
       my $h = $H[$i];
      return $i if ($h =~ m/Assigned by/ && $i>0);
    }
    print "Could not parse header line: \"$header\"\n";
    die;
  }




### The following not needed for now.

## Note add junk as zeroth element so we can retain 1-based numbering for months
my @monthabb = qw( junk Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec );
