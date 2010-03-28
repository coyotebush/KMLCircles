#!/usr/bin/perl

use lib '/home/www/kmlcircles.awardspace.info';

use warnings;
use strict;
use CGI;
use Geo::ProximityCircles;

my $q = CGI->new;
my $circles = new Geo::ProximityCircles;

# Get file
my $gpx_file = $q->upload('gpxfile');
if (defined $gpx_file) {
	$circles->read ($gpx_file);
} else {
	$q->header(-status => '400 Bad Request',
	           -type => 'text/plain');
	die 'Please upload a file';
}

# Options
$circles->color ($q->param('color'))  if (defined $q->param('color'));
$circles->radius($q->param('radius')) if (defined $q->param('radius'));

# Send the file
$q->header(-type => 'application/vnd.google-earth.kml+xml',
	-Content_Disposition => 'attachment;filename="circles.kml"');
print $circles->render(zip => 1, header => 1);
