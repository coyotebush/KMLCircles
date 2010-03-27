# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Geo-ProximityCircles.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 8;
BEGIN { use_ok('Geo::ProximityCircles') };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

# Test the default constructor
my $x = new Geo::ProximityCircles;
is ($x->color,  '990000ff', 'default color');
is ($x->radius, 0.1,        'default radius');
undef $x;

# Test constructor with arguments
my $x = new Geo::ProximityCircles (color => '00000000', radius => 0.2);
is ($x->color,  '00000000', 'custom constructor color');
is ($x->radius, 0.2,        'custom constructor radius');

# Test independently setting and getting parameters
$x->color({red => 55});
is_deeply ($x->color, {red => 55}, 'custom color hash');

$x->radius(0.23);
is ($x->radius, 0.23, 'custom radius');

# Test that color is included properly in output
my $color = {red => 122, green => 34, blue => 91, alpha => 201};
$x->color($color);
like($x->render, qr/c95b227a/i, "hex color in KML");

