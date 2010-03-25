#!/usr/bin/perl

use warnings;
use strict;
use Math::Trig qw(deg2rad rad2deg pi pi2 great_circle_destination);
use Getopt::Std 'getopts';
use Pod::Usage 'pod2usage';

use constant ANGLESTEP   => pi/10;     # in radians
use constant EARTHRADIUS => 3963.1676; # in miles

# Handle options
my %options = ();
getopts("r:o:c:a:", \%options);

pod2usage ("") if (not defined $options{o});

# Output file
open(KMLOUT, '>', $options{o});

# Optional arguments
my $radius =  2.52323419e-5; # 0.1 mile default
$radius = $options{r}/EARTHRADIUS if defined $options{r};
my $color = "0000ff"; # Red default;
if (defined $options{c})
{
	($options{c} =~ /[0-9a-f]{6}/i) ? $color = $options{c}
	: pod2usage ("Invalid value for -c argument");
}
my $alpha = "99";
$alpha = $options{a} if defined $options{a} and ($options{a} =~ /[0-9a-f]{2}/i);


# Print KML file beginning
print KMLOUT <<EndOfTheBeginning;
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
<Document>
<Folder>
<name>Circles</name>
<visibility>1</visibility>
<Style id="circles">
  <LineStyle>
    <color>ff$color</color>
    <width>2</width>
  </LineStyle>
  <PolyStyle>
    <color>$alpha$color</color>
  </PolyStyle>
</Style>
EndOfTheBeginning

# Read one waypoint per line
while (<>)
{
	# Extract the coordinates
	chomp;
	my ($lat, $lon, $name) = split(/,\s*/);
	
	# Print circle to KML
	print KMLOUT <<TheEnd;
<Placemark>
  <name><![CDATA[$name]]></name>
  <styleUrl>#circles</styleUrl>
  <Polygon>
    <tessellate>1</tessellate>
    <altitudeMode>clampToGround</altitudeMode>
    <outerBoundaryIs><LinearRing><coordinates>
TheEnd
	my $angle = 0;
	my $theta = deg2rad($lon);
	my $phi = deg2rad(90 - $lat);
	do
	{
		# Project a waypoint
		$angle += ANGLESTEP;
		my ($thetad, $phid, $dird) = great_circle_destination
			($theta, $phi, $angle, $radius);
		print KMLOUT rad2deg($thetad).','.rad2deg($phid)."\n";
	} while ($angle <= pi2);
	
	print KMLOUT <<TheEnd;
    </coordinates></LinearRing></outerBoundaryIs>
  </Polygon>
</Placemark>
TheEnd
}

# End KML file
print KMLOUT <<EndOfTheEnd;
</Folder>
</Document>
</kml>
EndOfTheEnd

=head1 NAME

kmlcircles - draw circles around waypoints

=head1 SYNOPSIS

kmlcircles [-a alpha] [-c color] [-r radius] -o outfile [infile...]

=head1 DESCRIPTION

This program reads waypoints in CSV format and writes a KML file containing
circles surrounding the waypoints at a specified distance.

=head1 OPTIONS

=over

=item -o outfile

KML filename to write to.

=item -a alpha

Alpha value for the circle fill, expressed as two hexadecimal digits from
00 (transparent) to ff (opaque). Default: 99.

=item -c color

Color for the circle fill and border, expressed in RGB using 6 hexadecimal
digits. Default: ff0000 (red).

=item -r radius

Radius for the circles, in miles. Default: 0.1.

=back

=head1 ARGUMENTS

Any other arguments given on the command line are taken as filenames to read CSV
data from. If none are specified, standard input will be used.

CSV format is expected to contain each waypoint on a line
with commas separating the latitude, longitude, and name, in that order.
Latitude and longitude are expected to be in decimal degree format.

=head1 SEE ALSO

L<Math::Trig>

=cut
