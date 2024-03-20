use strict;
use warnings;

use Tags::HTML::HTTP::Headers;
use Test::More 'tests' => 2;
use Test::NoWarnings;

# Test.
is($Tags::HTML::HTTP::Headers::VERSION, 0.01, 'Version.');
