DeviceAtlas::API - DeviceAtlas Enterprise API for Perl
=================
Thank you Derek Smith (https://github.com/clok) for reviewing and packing in a package
```
perl ./Build.PL
./Build test
./Build install (may require sudo)
```

This will build, test and install the ```DeviceAtlas::API``` perl module.  This will require ```Module::Build```.

This module supports perldoc: ```perldoc DeviceAtlas::API```

Dependencies
--------------
Modules:

```
JSON::XS
```
The use of this API requires a DeviceAtlas Enterprise JSON file that can be obtained with a license.  In order to properly test the API please place a copy of the JSON file in the test data directory as: ```t/data/donotadd.json```

###Usage###
```perl
use DeviceAtlas::API;
my $parser = DeviceAtlas::API->new('path_to_json_file');
```
Cheers!

Module Description
==================
###MAIN METHODS###

####new####

  Initializes a new DeviceAtlas API object an calls ```_init```

####getProperties####

  Given an input User Agent string, parse and traverse the tree to gather all available properties for that User Agent. This is the main function that should be used. Calls ```trim```, ```seekProperties```, ```propertFromId```, ```valueAsTypedFromId```, ```valueFromId```.  This will return a hash refernce with ALL available properties for a given User Agent.

####getTreeFromString####

  Loads the JSON tree from file path.  Called by ```_init``` and results are stored in ```$self->{input}```. Loads tree into ```$self->{tree}```.

####listProperties####

  Returns a hash reference to s list of all available named properties in a tree.

####idFromProperty####

  Given a named property, returns the int 'id' for that property. If that property does not exists, then warn that it is not in the tree.

####propertyFromId####

  Given an int 'id', return the named property for that 'id'.

####trim####

  Removes leading whitespace and trailing whitespace + eol chars from string.

####getProperty####

  Given a sought property, return the value of that property if it is defined.

####valueFromId####

  Given an in 'id', return the value for that 'id' from the tree.

####seekProperties####

  Traverses the depths of the tree to determine the properties for a matched User Agent.

####valueAsTypedFromId####

  Returns a tree object pertaining to the given 'id'.

  * Currently not functioning.

###SUPPORT METHODS###

####input####

  Accessor for ```$self->{input}```

####tree####

  Accessor for ```$self->{tree}```

###PRIVATE METHODS###

####_init####

  Called by ```new``` and calls ```getTreeFromString```

