#! /usr/bin/env perl

use strict;
use warnings;

use Time::HiRes;
use Data::Dumper;
use DAParser;
use Getopt::Std;

# Timer Module
{
   package Timer;

   sub new {
      my $class = shift;
      $class = ref($class) || $class;

      my $self = {};
      $self->{START} = undef;
      $self->{STOP} = undef;
      $self->{DELTA} = undef;

      bless $self, $class;

      return $self;
   }

   sub start {
      my $self = shift;
      $self->{START} = Time::HiRes::time;
   }

   sub stop {
      my $self = shift;
      $self->{STOP} = Time::HiRes::time;
      $self->_delta;
   }

   sub delta {
      my $self = shift;
      return sprintf("%.6f", $self->{DELTA});
   }

   sub _delta {
      my $self = shift;
      $self->{DELTA} = $self->{STOP} - $self->{START};
   }
}

my %opts;
# Options
getopts('j:l:hD', \%opts);

my $t = DAParser->new();
$t->{input} = $opts{j};
my $tree = $t->getTreeFromString;

open (F, $opts{l}) || die "Couldn't open $opts{l} UA\n";

my $timer = Timer->new;
my $cnt = 0;
$timer->start;
while (<F>) {
   my $out = $t->getProperties($tree,"$_");
	print &Dumper($out);
	$cnt++;
}
$timer->stop;
print "Processed ".$cnt." in ".$timer->delta." seconds\n";
print int($cnt / $timer->delta)." UA per Second\n";
