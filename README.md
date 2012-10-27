DeviceAtlas::API - DeviceAtlas Enterprise API for Perl
=================

Thank you very much to the initial work done by [darkonie](https://github.com/darkonie/Device-atlas-API-in-Perl "Maksym Naboka") for building a good starting point.

This work was done for [Oversee.net](http://www.oversee.net/ "Oversee.net") with use of the [DeviceAtlas Enterprise Liscense](http://deviceatlas.com/resourcecentre/Get+Started/Enterprise+API).

```
perl ./Build.PL
./Build test
./Build install (may require sudo)
```

This will build, test and install the ```DeviceAtlas::API``` perl module.  This will require ```Module::Build```.

Dependencies
--------------
Modules:

```
JSON::XS
```
The use of this API requires a DeviceAtlas Enterprise JSON file that can be obtained with a license.  In order to properly test the API please place a copy of the JSON file in the test data directory as: ```t/data/donotadd.json```

Cheers!
