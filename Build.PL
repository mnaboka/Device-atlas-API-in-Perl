#!/usr/bin/env perl

use strict;
use warnings;

use Module::Build;

Module::Build->new(
	module_name        => 'DeviceAtlas::API',
	dist_abstract      => 'DeviceAtlas Enterprise API',
	dist_author        => 'Derek Smith <derek@clokwork.net>',
	build_requires     => {
		'JSON'          => 0,
		'JSON::XS'      => 0,
	},
	requires           => {
		'JSON'          => 0,
		'JSON::XS'      => 0,
	}
)->create_build_script;
