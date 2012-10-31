use strict;
use warnings;

package DeviceAtlas::API;

use JSON;

my $VERSION = '1.1';

my $jcoder = JSON::XS->new->allow_nonref;

sub new {
	my $class = shift;
	$class = ref($class) || $class;

	my $self = {
		input => shift,
		tree  => undef,
		debug => 0
	};

	bless $self, $class;

	$self->_init;

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
	my $self = shift;
   my %types = (
		"s"=>"string",
		"b"=>"boolean",
		"i"=>"integer",
		"d"=>"date",
		"u"=>"unknown"
	);

   my %listProperties=();
   foreach my $property (@{$self->tree->{p}}) {
      $listProperties{substr($property,1)} = $types{substr($property,0,1)};
   }
   return \%listProperties;

}

sub idFromProperty {
	my $self = shift;
	my $prop = shift;
	if ($self->tree->{pn}->{$prop}) {
		my $i = $self->tree->{pn}->{$prop} - 1;
		return $i;
	} else {
		warn "The property $prop is not known in this tree.\n";
	}
}

sub propertyFromId {
	my $self = shift;
	my $id = shift;
   return substr($self->tree->{p}->[$id], 1) if $id;
}

sub trim {
	my $self = shift;
	my $string = shift;
   for ($string) {
      s/^\s+//;
      s/\s+$//;
   }
   return $string;
}

sub getProperty {
	my $self = shift;
	my $post_parse = shift;
	my $sought = shift;

	defined $post_parse->{$sought} ? return $post_parse->{$sought} : return 0;
}

sub valueFromId {
	my $self = shift;
	my $id = shift;
   return $self->tree->{v}->[$id] if $id;
}

# TODO: refactor
sub seekProperties {
   my ($self, $node, $string, $properties, $sought, $matched, $rules) = @_;
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
			if (@$sought
				 && ( !defined $node->{m}
						|| ( defined $node->{m} && !defined $node->{m}->[$property] )
					)
			 ) {
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
	my $self = shift;
	my $userAgent = shift;
	my $typedValues = shift || undef;

   my @idProperties = ();
   my $matched = "";
   my @sought = ();
   #my $rules = $self->tree->{r}->[1];
   my $rules = "";

   $userAgent = $self->trim($userAgent);
   $self->seekProperties($self->tree->{t}, $userAgent, \@idProperties, \@sought, \$matched, \$rules);

   my %properties = ();
   my $id = 0;

   foreach my $value (@idProperties) {
      if (defined $typedValues) {
			$properties{$self->propertyFromId($id)} = $self->valueAsTypedFromId($value, $id);
      } else {
			$properties{$self->propertyFromId($id)} = $self->valueFromId($value);
      }
      $id++;
   }

   $properties{"_matched"} = $matched;
   $properties{"_unmatched"} = substr($userAgent, length($matched));

   return \%properties;
}

# TODO: check if valid, Not functioning
sub valueAsTypedFromId {
	my $self = shift;
	my $id = shift;
   my $obj = $self->tree->{v}->[$id];

   return $obj;
}

sub input {
	my $self = shift;
	return $self->{input};
}

sub tree {
	my $self = shift;
	return $self->{tree};
}

sub _init {
	my $self = shift;
	$self->{tree} = $self->getTreeFromString;
}

1;

__END__

=pod

=head1 NAME

  DeviceAtlas::API

=head1 DESCRIPTION

DeviceAtlas::API - DeviceAtlas Enterprise API for Perl

Thank you very much to the initial work done by [darkonie](https://github.com/darkonie/Device-atlas-API-in-Perl "Maksym Naboka") for building a good starting point.

This work was done for [Oversee.net](http://www.oversee.net/ "Oversee.net") with use of the [DeviceAtlas Enterprise Liscense](http://deviceatlas.com/resourcecentre/Get+Started/Enterprise+API).

=head1 DEPENDENCIES

Modules:
Mobule::Build
JSON::XS

The use of this API requires a DeviceAtlas Enterprise JSON file that can be obtained with a license.  In order to properly test the API please place a copy of the JSON file in the test data directory as: t/data/donotadd.json

Cheers!

=head1 SYNOPSIS

  use DeviceAtlas::API;

  my $parser = DeviceAtlas::API->new('path_to_json_file');

=head1 AUTHOR

  Derek Smith (dsmith [at] oversee.net)

=head1 MAIN METHODS

=over 4

=item B<new>

  Initializes a new DeviceAtlas API object an calls "_init"

=item B<getProperties>

  Given an input User Agent string, parse and traverse the tree to gather all available properties for that User Agent. This is the main function that should be used. Calls 'trim', 'seekProperties', 'propertFromId', 'valueAsTypedFromId', 'valueFromId'.  This will return a hash refernce with ALL available properties for a given User Agent.

=item B<getTreeFromString>

  Loads the JSON tree from file path.  Called by _init and results are stored in $self->{input}. Loads tree into $self->{tree}.

=item B<listProperties>

  Returns a hash reference to s list of all available named properties in a tree.

=item B<idFromProperty>

  Given a named property, returns the int 'id' for that property. If that property does not exists, then warn that it is not in the tree.

=item B<propertyFromId>

  Given an int 'id', return the named property for that 'id'.

=item B<trim>

  Removes leading whitespace and trailing whitespace + eol chars from string.

=item B<getProperty>

  Given a sought property, return the value of that property if it is defined.

=item B<valueFromId>

  Given an in 'id', return the value for that 'id' from the tree.

=item B<seekProperties>

  Traverses the depths of the tree to determine the properties for a matched User Agent.

=item B<valueAsTypedFromId>

  Returns a tree object pertaining to the given 'id'.

  ***Currently not functioning.

=back

=head1 SUPPORT METHODS

=over 4

=item B<input>

  Accessor for $self->{input}

=item B<tree>

  Accessor for $self->{tree}

=back

=head1 PRIVATE METHODS

=over 4

=item B<_init>

  Called by 'new' and calls 'getTreeFromString'

=back

=cut

