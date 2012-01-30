#!/usr/bin/perl

#
# maksym.naboka@gmail.com
#

package Mobi_Mtld_DA_Api;
use JSON::Parse 'json_to_perl';
use Data::Dumper;
use warnings;
use strict;
use Carp;

our $debug = 0;

sub new() {
	my $class = shift;
	my $self = {
		#input => '20111122.json',
		input => '',
	};

	return bless $self, $class;

}

sub getTreeFromString() {
	my $self = shift;
	local $/;
	open( my $fh, '<', $self->{input}) or die "Cannot open file\n";
	my $json_text = <$fh>;
	my $tree = json_to_perl($json_text);
	my %pr = ();
        my %pn = ();
	my $i;
	foreach my $key(@{$tree->{p}}) {
		$pr{$key} = $i++;
		$pn{substr($key,1)} = $i;
	}
	undef $i;
	$tree->{pr} = \%pr;
	$tree->{pn} = \%pn;
	#$tree->{r} = [] if($tree->{r});

	return $tree;

}



sub listProperties() {
	my ($self,$tree) = @_;
	my %types = (
		"s"=>"string",
                "b"=>"boolean",
                "i"=>"integer",
                "d"=>"date",
                "u"=>"unknown");

	my %listProperties=();
	foreach my $property(@{$tree->{p}}) {
		$listProperties{substr($property,1)} = $types{substr($property,0,1)};
	}
	return \%listProperties;

}

sub idFromProperty() {
	my ($self,$tree,$property) = @_;
	if($tree->{pn}->{$property}) {
		return --$tree->{pn}->{$property} }
		else { croak "The property $property is not known in this tree.\n" }
}

sub propertyFromId() {
	my ($self,$tree,$id) = @_;
	return substr($tree->{p}->[$id], 1) if $id;

}

sub trim {
    my($self,$string)=@_;
    for ($string) {
        s/^\s+//;
        s/\s+$//;
        }
    return $string;
    }

sub getProperty() {
	my ($self,$tree, $userAgent, $property, $typedValue) = @_;
	my $propertyId = $self->idFromProperty($tree, $property);
	print "Property ID: $propertyId \n" if $debug;
	my @idProperties=();
	my @sought=();
	$sought[$propertyId] = 1;
	my $matched = "";
	my $unmatched = "";
	my $rules = $tree->{r}->{1};
	$userAgent = $self->trim($userAgent);
	$self->seekProperties($tree->{t}, $userAgent, \@idProperties, \@sought, \$matched, \$rules);
	if($#idProperties == 0){ croak "The property $property is invalid for the User Agent: $userAgent \n" }
	else { 
		print "sub: getProperty, \$idProperties[\$propertyId] = $idProperties[$propertyId] \n" if $debug;
		return $self->valueFromId($tree, $idProperties[$propertyId]);
	}

}

sub valueFromId() {
	my ($self,$tree, $id) = @_;
	return $tree->{v}->[$id] if $id;

}

sub seekProperties() {
	my ($self,$node, $string, $properties, $sought, $matched, $rules) = @_;
	my ($seek);
	my $unmatched = $string;
	
	if($node->{d}) {

	if (@$sought && scalar @{$sought} == 0) {
                                return;
                        }
                        foreach my $property(keys %{$node->{d}}) {
                                if (!@$sought || defined($sought->[$property])) {
                                        $properties->[$property] = $node->{d}->{$property};
                                        print "sub: seekProperties \$property = $property => \$node->{m}->[\$property] = $node->{m}->[$property] \n" if $debug;
                                }
                                if (@$sought &&
                                ( !defined($node->{m}) || ( defined($node->{m}) && !defined($node->{m}->[$property]) ) ) ){
                                        undef($sought->[$property]);
                                }
                        }
	}


	if($node->{'c'}) {
	for(my $c = 1; $c < length($string) + 1; $c++) {
                        $seek = substr($string, 0, $c);
                        if($node->{'c'}->{$seek}) {
                                $$matched .= $seek;
                                $self->seekProperties($node->{'c'}->{$seek}, substr($string, $c), $properties, $sought, $matched, $rules);
				last;
			}
	}
	}
}

sub getProperties() {
		my($self,$tree, $userAgent, $typedValues) = @_;
                my @idProperties = ();
                my $matched = "";
                my @sought = ();
    		#my $rules = $tree->{r}->[1];
		my $rules = "";
		$userAgent = $self->trim($userAgent);
                $self->seekProperties($tree->{t}, $userAgent, \@idProperties, \@sought, \$matched, \$rules);
                my %properties = ();
		my $id;
                foreach my $value (@idProperties) {
                        if ($typedValues) {
                                $properties{$self->propertyFromId($tree, $id)} = $self->valueAsTypedFromId($tree, $value, $id);
                        } else {
                                $properties{$self->propertyFromId($tree, $id)} = $self->valueFromId($tree, $value);
                        }
		$id++;
                }
                $properties{"_matched"} = $matched;
                $properties{"_unmatched"} = substr($userAgent, length($matched));
                return \%properties;
        }

sub valueAsTypedFromId() {
		my($self,$tree, $id, $propertyId) = @_;
                my $obj = $tree->{v}->[$id];
                #switch ($tree['p'][$propertyId]{0}) {
                #        case 's':
                #                settype($obj, "string");
                #                break;
                #        case 'b':
                #                settype($obj, "boolean");
                #                break;
                #        case 'i':
                #                settype($obj, "integer");
                #                break;
                #        case 'd':
                #                settype($obj, "string");
                #                break;
                #}
                return $obj;
        }

package main;
use Data::Dumper;

sub usage() {
print <<EOF;
Usage:

	$0 <devices.json> <user_agents.txt>

EOF

exit;
}

my $show_all=0;

my $t = Mobi_Mtld_DA_Api->new();
$t->{input} = shift || &usage;
my $tree = $t->getTreeFromString;
#print &Dumper($t->listProperties($tree));
#print $t->getProperty($tree,$useragent, $attr) if($useragent && $attr);
#$out = $t->getProperties($tree,"$_");

open (F, shift ) or &usage;

while(<F>) {
my $out = $t->getProperties($tree,"$_");
print "START " . $out->{'vendor'} . " ". $out->{'model'} . "\n";
print &Dumper($out);
print "END " . $out->{'vendor'} . " ". $out->{'model'} . "\n\n";
}



