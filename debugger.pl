#! /usr/bin/env perl

use strict;
use warnings;

use Getopt::Std;
use Data::Dumper;

use DeviceAtlas::API;

my %opts;
getopts('j:u:', \%opts);

my $parser = DeviceAtlas::API->new($opts{j});

my $data = $parser->getProperties($opts{u});

print Dumper $data;
