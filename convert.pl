#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;
#Load the file 

my $file = $ARGV[0];
my $DEBUG = 0;

my $numberOfLineToDeleteForEachDay = 3;

#Load the file in array for ez processing 
my $menu = `pdftotext -layout "$file" -`;
my @file = split /\n/, $menu;

#Go to days of the week
@file = splice @file, 3;

print Dumper(\@file) if $DEBUG;

my @daysOfTheWeek;

while($file[0] =~ / ([a-zA-Z0-9].*?)(  |$)/)
{
  push @daysOfTheWeek, [$1];
  $file[0] =~ s/$1/ /;
}

print Dumper(\@daysOfTheWeek) if $DEBUG;

#Begin to catch the menu 
@file = splice @file, 1;
my $arrSize = scalar @daysOfTheWeek or die("no days detected");

FILE: while(scalar @file > 0)
{
  my $counter = 0;
  while($file[0] =~ /([^ |\n].*?)(  |$)/)
  {
    last FILE if $daysOfTheWeek[$counter][0] eq $1; # R2
    push @{$daysOfTheWeek[$counter]}, $1;
    my $remove = quotemeta $1;
    $file[0] =~ s/$remove/ /;
    $counter++;
  }

  #Special cases 
  if($counter == 1)
  {
    my $lastElement = scalar @{$daysOfTheWeek[0]};
    for(my $i = 1; $i < $arrSize; $i++)
    {
      push @{$daysOfTheWeek[$i]}, $daysOfTheWeek[0]->[$lastElement - 1];
    }
  }

  @file = splice @file, 1;
}

#Remove the two last line of each days 
#To lazy to write the map
for(my $i = 0; $i < $arrSize; $i++)
{
  my $lengthMenu = scalar @{$daysOfTheWeek[$i]};
  @{$daysOfTheWeek[$i]} = splice @{$daysOfTheWeek[$i]},0, $lengthMenu - $numberOfLineToDeleteForEachDay;
}

print Dumper(\@daysOfTheWeek) if $DEBUG;

#Print all the files 

my $fileHandler;
for(my $i = 0; $i < $arrSize; $i++)
{
  my $filename = $daysOfTheWeek[$i]->[0].".txt";
  print "writing to filename: $filename\n" if $DEBUG;
  open($fileHandler, ">", $filename);
  if(not $fileHandler)
  {
    print "Cannot write: $!";
    exit(1);
  }
  
  shift @{$daysOfTheWeek[$i]};
  $fileHandler->print(join("\n", @{$daysOfTheWeek[$i]}));

  close $fileHandler;
}
