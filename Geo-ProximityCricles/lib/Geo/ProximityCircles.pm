package Geo::ProximityCircles;

use 5.008008;
use strict;
use warnings;

use Math::Trig qw(deg2rad rad2deg pi pi2 great_circle_destination);
use Geo::GoogleEarth::Pluggable;
use Geo::Gpx;

=head1 NAME

Geo::ProximityCircles - generate circles around waypoints

=head1 SYNOPSIS

  use Geo::ProximityCircles;
  open (my $gpx, '<', 'data.gpx');
  open (my $kml, '>', 'circles.kml');
  my $circles = new Geo::ProximityCircles(input => $gpx,
                                          color => 'ff0000'); # Red
  print $kml $circles->kml->render;

=head1 DESCRIPTION

Given a set of waypoints, a Google Earth file can be written containing circles
that surround said waypoints. This is useful to visualize proximity
restrictions, for instance in geocaching (L<http://www.geocaching.com/>).

=head1 MEMBERS

=over 4

=cut

#our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Geo::ProximityCircles ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);

our $VERSION = '0.01';

sub new {
	
}
=item * read($fh)

Loads waypoints from a GPX file.

  open($gpx, '<', 'wpts.gpx')
  $circles->read($gpx);

=cut

sub read {
	
}

=item * color( [new_color] )

Circle color, as accepted by L<Geo::GoogleEarth::Pluggable::Style/color>.

  $circles->color('9900ff00');
  $circles->color({red => 0, green => 255, blue => 0, alpha => 153});
  $circles->color # => '9900ff00'

=cut

sub color {
	my $self = shift;
	my $newval = shift;
	if (defined $newval) {
		$self->{'color'} = reverse($newval) ;
	}
	return $self->{'color'};
}


#	
#for my $attr ( @META, @ATTR ) {
#    no strict 'refs';
#    $attr = sub {
#      my $self = shift;
#      $self->{$attr} = shift if @_;
#      return $self->{$attr};
#    };
#  }

# Preloaded methods go here.

1;
__END__


=item * kml

Access to the L<Geo::GoogleEarth::Pluggable> document.

Get KML

  $circles->kml->render;

Get KMZ

  $circles->kml->archive;

Print KML HTTP header

  $circles->kml->header;

Print KMZ HTTP header

  $circles->kml->header_kmz;

=head1 HISTORY

=over 8

=item 0.01

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
