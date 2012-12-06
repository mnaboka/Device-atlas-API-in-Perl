#! /usr/bin/env perl

use strict;
use warnings;

use Data::Dumper;

use Test::More qw( no_plan );

$|=1;
use_ok('DeviceAtlas::API');

my $data_dir = 't/data/';

# Init a new parser
my $parser = DeviceAtlas::API->new($data_dir.'donotadd.json');
ok( defined $parser->{input},
	 'JSON file not set' );

my $input = $parser->input;
ok( defined $input,
	 'input fxn not working' );

ok( defined $parser->{tree},
	 'Tree not loaded' );

my $tree = $parser->tree;
ok( defined $tree,
	 'tree fxn not working' );

my $id = $parser->idFromProperty('isRobot');
is( $id,
	 4,
	 'ID not properly set by idFromProperty');

my $prop = $parser->propertyFromId(4);
is( $prop,
	 'isRobot',
	 'Property not properly set by propertyFromId');

my $uas = "Mozilla/5.0 (iPhone; CPU OS 5_1 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Mobile/9B206 Safari/7534.48";
my $ret_hash = $parser->getProperties($uas);
ok( defined $ret_hash,
	 'UAS not parsed' );

my $undef = $parser->getProperty($ret_hash, 'isFeedReader');
is( $undef,
	 0,
	 'undefined value not working for getProperty');

my $zero = $parser->getProperty($ret_hash, 'csd');
is( $zero,
	 0,
	 'zero value not working for getProperty');

my $bool = $parser->getProperty($ret_hash, 'mobileDevice');
is( $bool,
	 1,
	 'boolean true value not working for getProperty');

my $string = $parser->getProperty($ret_hash, 'vendor');
is( $string,
	 'Apple',
	 'string value not working for getProperty');
