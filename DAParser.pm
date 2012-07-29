#! /usr/bin/env perl

use strict;
use warnings;

package DAParser;

use JSON;
use Carp;

my $jcoder = JSON::XS->new->allow_nonref;

sub new {
    my $class = shift;
    $class = ref($class) || $class;

    my $self = {
		input => '',
		debug => 0
	       };

    bless $self, $class;
    return $self;
}

sub getTreeFromString {
   my $self = shift;
   local $/;
   open( my $fh, '<', $self->{input}) or die "Cannot open file\n";
   my $json_text = <$fh>;
   my $tree = $jcoder->decode($json_text);
   close $fh;
   my %pr = ();
   my %pn = ();
   my $i;
   foreach my $key (@{$tree->{p}}) {
      $pr{$key} = $i++;
      $pn{substr($key,1)} = $i;
   }
   undef $i;
   $tree->{pr} = \%pr;
   $tree->{pn} = \%pn;

   return $tree;
}

sub listProperties {
   my ($self,$tree) = @_;
   my %types = (
		"s"=>"string",
                "b"=>"boolean",
                "i"=>"integer",
                "d"=>"date",
                "u"=>"unknown");

   my %listProperties=();
   foreach my $property (@{$tree->{p}}) {
      $listProperties{substr($property,1)} = $types{substr($property,0,1)};
   }
   return \%listProperties;

}

sub idFromProperty {
   my ($self,$tree,$property) = @_;
   if ($tree->{pn}->{$property}) {
      return --$tree->{pn}->{$property};
   } else {
      croak "The property $property is not known in this tree.\n";
   }
}

sub propertyFromId {
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

sub getProperty {
   my ($self,$tree, $userAgent, $property, $typedValue) = @_;
   my $propertyId = $self->idFromProperty($tree, $property);
   print "Property ID: $propertyId \n" if $self->{debug};
   my @idProperties=();
   my @sought=();
   $sought[$propertyId] = 1;
   my $matched = "";
   my $unmatched = "";
   my $rules = $tree->{r}->{1};
   $userAgent = $self->trim($userAgent);
   $self->seekProperties($tree->{t}, $userAgent, \@idProperties, \@sought, \$matched, \$rules);
   if ($#idProperties == 0) {
      croak "The property $property is invalid for the User Agent: $userAgent \n";
   } else {
      print "sub: getProperty, \$idProperties[\$propertyId] = $idProperties[$propertyId] \n" if $self->{debug};
      return $self->valueFromId($tree, $idProperties[$propertyId]);
   }

}

sub valueFromId {
   my ($self,$tree, $id) = @_;
   return $tree->{v}->[$id] if $id;
}

sub seekProperties {
   my ($self,$node, $string, $properties, $sought, $matched, $rules) = @_;
   my ($seek);
   my $unmatched = $string;

   if ($node->{d}) {
      if (@$sought && scalar @{$sought} == 0) {
	 return;
      }
      foreach my $property (keys %{$node->{d}}) {
	 if (!@$sought || defined($sought->[$property])) {
	    $properties->[$property] = $node->{d}->{$property};
	    print "sub: seekProperties \$property = $property => \$node->{m}->[\$property] = $node->{m}->[$property] \n" if $self->{debug};
	 }
	 if (@$sought &&
	     ( !defined($node->{m}) || ( defined($node->{m}) && !defined($node->{m}->[$property]) ) ) ) {
	    undef($sought->[$property]);
	 }
      }
   }

   if ($node->{'c'}) {
      for (my $c = 1; $c < length($string) + 1; $c++) {
	 $seek = substr($string, 0, $c);
	 if ($node->{'c'}->{$seek}) {
	    $$matched .= $seek;
	    $self->seekProperties($node->{'c'}->{$seek}, substr($string, $c), $properties, $sought, $matched, $rules);
	    last;
	 }
      }
   }
}

sub getProperties {
   my($self, $tree, $userAgent, $typedValues) = @_;
   my @idProperties = ();
   my $matched = "";
   my @sought = ();
   #my $rules = $tree->{r}->[1];
   my $rules = "";
   $userAgent = $self->trim($userAgent);
   $self->seekProperties($tree->{t}, $userAgent, \@idProperties, \@sought, \$matched, \$rules);
   my %properties = ();
   my $id = 0;
   foreach my $value (@idProperties) {
      if (defined $typedValues) {
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

sub valueAsTypedFromId {
   my($self,$tree, $id, $propertyId) = @_;
   my $obj = $tree->{v}->[$id];

   return $obj;
}

1;
