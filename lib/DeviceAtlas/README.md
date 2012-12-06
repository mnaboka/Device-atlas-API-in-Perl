DeviceAtlas::API
----------------
# NAME

    DeviceAtlas::API

# DESCRIPTION

DeviceAtlas::API - DeviceAtlas Enterprise API for Perl

Thank you very much to the initial work done by \[darkonie\](https://github.com/darkonie/Device-atlas-API-in-Perl "Maksym Naboka") for building a good starting point.

This work was done for \[Oversee.net\](http://www.oversee.net/ "Oversee.net") with use of the \[DeviceAtlas Enterprise Liscense\](http://deviceatlas.com/resourcecentre/Get+Started/Enterprise+API).

# DEPENDENCIES

Modules:
Mobule::Build
JSON::XS

The use of this API requires a DeviceAtlas Enterprise JSON file that can be obtained with a license.  In order to properly test the API please place a copy of the JSON file in the test data directory as: t/data/donotadd.json

Cheers!

# SYNOPSIS

    use DeviceAtlas::API;

    my $parser = DeviceAtlas::API->new('path_to_json_file');

# AUTHOR

    Derek Smith (dsmith [at] oversee.net)

# MAIN METHODS

- __new__

        Initializes a new DeviceAtlas API object an calls "_init"
- __getProperties__

        Given an input User Agent string, parse and traverse the tree to gather all available properties for that User Agent. This is the main function that should be used. Calls 'trim', 'seekProperties', 'propertFromId', 'valueAsTypedFromId', 'valueFromId'.  This will return a hash refernce with ALL available properties for a given User Agent.
- __getTreeFromString__

        Loads the JSON tree from file path.  Called by _init and results are stored in $self->{input}. Loads tree into $self->{tree}.
- __listProperties__

        Returns a hash reference to s list of all available named properties in a tree.
- __idFromProperty__

        Given a named property, returns the int 'id' for that property. If that property does not exists, then warn that it is not in the tree.
- __propertyFromId__

        Given an int 'id', return the named property for that 'id'.
- __trim__

        Removes leading whitespace and trailing whitespace + eol chars from string.
- __getProperty__

        Given a sought property, return the value of that property if it is defined.
- __valueFromId__

        Given an in 'id', return the value for that 'id' from the tree.
- __seekProperties__

        Traverses the depths of the tree to determine the properties for a matched User Agent.
- __valueAsTypedFromId__

        Returns a tree object pertaining to the given 'id'.

        ***Currently not functioning.

# SUPPORT METHODS

- __input__

        Accessor for $self->{input}
- __tree__

        Accessor for $self->{tree}

# PRIVATE METHODS

- __\_init__

        Called by 'new' and calls 'getTreeFromString'

