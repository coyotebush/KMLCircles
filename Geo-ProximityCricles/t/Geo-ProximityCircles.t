# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Geo-ProximityCircles.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 7;
BEGIN { use_ok('Geo::ProximityCircles') };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

# Test the default constructor
my $d = new Geo::ProximityCircles;
is ($d->color,  '9900ff00', 'default color');
is ($d->radius, 0.1,        'default radius');

# Test constructor with arguments
my $x = new Geo::ProximityCircles (color => '00000000', radius => 0.2);
is ($x->color,  '00000000', 'custom constructor color');
is ($x->radius, 0.2,        'custom constructor radius');

# Test independently setting parameters
my $x->color({red => 55});
is ($x->color, {red => 55}, 'custom color hash');

my $x->radius(0.23);
is ($x->radius, 0.23, 'custom radius');

