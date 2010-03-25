#!/usr/bin/perl -T

# kmlcircles for web
use strict;
use Math::Trig 'deg2rad';
use Math::Trig 'rad2deg';
use Math::Trig 'pi2';
use Math::Trig 'pi';
use Math::Trig 'great_circle_destination';
use Getopt::Std 'getopts';
use Pod::Usage 'pod2usage';
use CGI;
use CGI 'header';
use CGI ':cgi-lib';

use constant ANGLESTEP   => pi/10;     # in radians
use constant EARTHRADIUS => 3963.1676; # in miles

print header(-type => 'application/vnd.google-earth.kml+xml',
	-Content_Disposition => 'attachment;filename="circles.kml"');
my $options = Vars;

# Optional arguments
my $radius =  2.52323419e-5; # 0.1 mile default
$radius = $options->{r}/EARTHRADIUS if defined $options->{r};
my $color = "0000ff"; # Red default;
if (defined $options->{c})
{
	($options->{c} =~ /[0-9a-f]{6}/i) ? $color = $options->{c}
	: pod2usage ("Invalid value for -c argument");
}
my $alpha = "99";
$alpha = $options->{a} if defined $options->{a} and ($options->{a} =~ /[0-9a-f]{2}/i);


# Print KML file beginning
print <<EndOfTheBeginning;
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
foreach (split(/[\n\r]+/, $options->{data}))
{
	# Extract the coordinates
	chomp;
	my ($lat, $lon, $name) = split(/,\s*/);
	
	# Print circle to KML
	print <<TheEnd;
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
		print rad2deg($thetad).','.rad2deg($phid)."\n";
	} while ($angle <= pi2);
	
	print <<TheEnd;
    </coordinates></LinearRing></outerBoundaryIs>
  </Polygon>
</Placemark>
TheEnd
}

# End KML file
print <<EndOfTheEnd;
</Folder>
</Document>
</kml>
EndOfTheEnd

=head1 NAME

kmlcircles - draws circles around waypoints in KML

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
Latitude and Longitude are expected to be in decimal degree format.

=head1 SEE ALSO

L<Math::Trig>

=cut
