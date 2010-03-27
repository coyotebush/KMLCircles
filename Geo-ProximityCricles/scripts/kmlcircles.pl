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

=head1 SYNOPSIS

kmlcircles [-c color] [-r radius] outfile infile1 [infile2...]

=head1 DESCRIPTION

Given a set of waypoints contained in GPX files, a Google Earth file can be
written containing circles that surround said waypoints. This is useful to
visualize proximity restrictions, for instance in geocaching
(L<http://www.geocaching.com/>).

=head1 OPTIONS

=over

=item -c color

Color for the circle fill and border, expressed in RGB using 6 hexadecimal
digits. Default: ff0000 (red).

=item -r radius

Radius for the circles, in miles. Default: 0.1.

=back

=head1 ARGUMENTS

The first argument is taken as a filename to which KML output will be written.

Any other arguments are assumed to be GPX files containing the desired
waypoints.

=head1 SEE ALSO

L<Geo::GoogleEarth::ProximityCircles>

=cut
