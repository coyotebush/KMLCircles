package Geo::ProximityCircles;

use 5.008008;
use strict;
use warnings;

use Math::Trig qw(deg2rad rad2deg pi pi2 great_circle_destination);
use Geo::GoogleEarth::Pluggable;
use Geo::Gpx;

use constant ANGLESTEP   => pi/10;     # in radians
use constant EARTHRADIUS => 3963.1676; # in miles

our $VERSION = '0.01';

=head1 NAME

Geo::ProximityCircles - generate circles around waypoints

=head1 SYNOPSIS

  use Geo::ProximityCircles;
  open (my $gpx, '<', 'data.gpx');
  open (my $kml, '>', 'circles.kml');
  my $circles = new Geo::ProximityCircles(read => $gpx,
                                          color => 'ff0000'); # Red
  print $kml $circles->kml->render;

=head1 DESCRIPTION

Given a set of waypoints, a Google Earth file can be written containing circles
that surround said waypoints. This is useful to visualize proximity
restrictions, for instance in geocaching (L<http://www.geocaching.com/>).

=head1 MEMBERS

=over 4

=cut

=item * new

Options may be passed to set attributes as with the accessor methods.

  my $circles = new Geo::ProximityCircles(
  	color => {red => 0, green => 255, blue => 0, alpha => 153},
  	radius => 0.2
  };

=cut

sub new {
	my $class = shift;
	# Default values
	my $self = {
		_radius => 2.52323419e-5,
		_kml => Geo::GoogleEarth::Pluggable->new(name => 'ProximityCircles'),
	};
	bless $self, $class;
	$self->color('990000ff');
	my %params = @_;
	for my $attrib (keys %params) {
		$self->$attrib ($params{$attrib}) if $self->can($attrib);
    }
    return $self;
}

=item * read($fh)

Loads waypoints from a GPX file.

  open($gpx, '<', 'wpts.gpx')
  $circles->read($gpx);

=cut

sub read {
	my $self = shift;
	my $fh = shift;
	my $gpx = Geo::Gpx->new(input => $fh);
	foreach my $wpt ($gpx->waypoints()) {
		$self->_add($wpt->[0]{'lat'}, $wpt->[0]{'lon'}, $wpt->[0]{'name'});
	}
}

=item * color( [new_color] )

Circle color, as accepted by L<Geo::GoogleEarth::Pluggable::Style/color>.

  $circles->color('9900ff00'); # Default color
  $circles->color({red => 0, green => 255, blue => 0, alpha => 153}); # Same
  $circles->color; # => '9900ff00'

=cut

sub color {
	my $self = shift;
	my $newval = shift;
	if (defined $newval) {
		if (defined $self->{'_style'}) {
			$self->{'_style'}->{'PolyStyle'}->{'color'} = $newval;
		} else {
			$self->{'_style'} = $self->{'_kml'}->PolyStyle (color => $newval);
		}
	}
	return $self->{'_style'}->{'PolyStyle'}->{'color'};
}

=item * radius( [new_radius] )

Circle radius, in miles.

  $circles->radius(0.23);
  $circles->radius; # => 0.23;

=cut

sub radius {
	my $self = shift;
	my $newval = shift;
	if (defined $newval) {
		$self->{'_radius'} = $newval/EARTHRADIUS;
	}
	return $self->{'_radius'}*EARTHRADIUS;
}

=item * render

Render KML to a string.

Available options: 'zip' to get zipped (KMZ) output, 'header' to include
appropriate HTTP headers.

  print $circles->render;
  print $circles->render(zip => 1, header => 1); # in a CGI script, perhaps

=cut

sub render {
	my $self = shift;
	my %options = @_;
	if (defined $options{'zip'} and $options{'zip'}) {
		if (defined $options{'header'} and $options{'header'}) {
			return $self->{'_kml'}->header_kmz . $self->{'_kml'}->archive;
		} else {
			return $self->{'_kml'}->archive;
		}
	} else {
		if (defined $options{'header'} and $options{'header'}) {
			return $self->{'_kml'}->header_kml . $self->{'_kml'}->render;
		} else {
			return $self->{'_kml'}->render;
		}
	}
}

# Add a circle
sub _add {
	my ($self, $lat, $lon, $name) = @_;
	my $angle = 0;
	my $theta = deg2rad($lon);
	my $phi = deg2rad(90 - $lat);
	my @points = ();
	do {
		# Project a waypoint
		$angle += ANGLESTEP;
		my ($thetad, $phid, $dird) = great_circle_destination
			($theta, $phi, $angle, $self->{_radius});
		push(@points, [rad2deg($thetad), rad2deg($phid), 0]);
	} while ($angle <= pi2);
	$self->{'_kml'}->LinearRing(
		name => $name,
		coordinates => \@points,
		style => $self->{'_style'}
	);
}

1;
__END__

=back

=head1 HISTORY

=over 8

=item * 0.01

Original version

=back



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Corey (coyotebush22@gmail.com)

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Corey

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.


=cut
