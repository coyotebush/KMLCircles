#!/usr/bin/perl

use warnings;
use strict;
use Getopt::Std 'getopts';
use Pod::Usage 'pod2usage';
use Geo::ProximityCircles;

# Handle options
my %options = ();
getopts("r:c:a:", \%options);
my $output_file = shift;
pod2usage("No output filename specified") unless defined $output_file;

# Set up object
my $circles = new Geo::ProximityCircles;

# Optional arguments
$circles->radius($options{r}) if defined $options{r};
$circles->color($options{c}) if defined $options{c};

# Load GPX files
while (my $gpx_file = shift) {
	open (my $fh, '<', $gpx_file);
	$circles->read($fh);
	close($fh);
}

# Output file
open(my $kml, '>', $output_file);
print $kml $circles->kml;
close($kml);

__END__
