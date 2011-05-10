package ShinyCMS::Controller::Root;

use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }


# Set the actions in this controller to be registered with no prefix, 
# so they function identically to actions created in MyApp.pm
__PACKAGE__->config->{ namespace } = '';


=head1 NAME

ShinyCMS::Controller::Root

=head1 DESCRIPTION

Root Controller for ShinyCMS.

=head1 METHODS

=cut


=head2 index

Forward to the CMS pages

=cut

sub index : Path : Args(0) {
	my ( $self, $c ) = @_;
	
	# Redirect to the default index page in the CMS pages section
	$c->detach( 'Pages', 'index' );
}


=head2 admin

Forward to the admin area

=cut

sub admin : Path( 'admin' ) : Args( 0 ) {
	my ( $self, $c ) = @_;
	
	# Redirect to admin login
	$c->go( 'Admin::User', 'login' );
}


=head2 login

Forward to the user-facing login

=cut

sub login : Path( 'login' ) : Args( 0 ) {
	my ( $self, $c ) = @_;
	
	# Redirect to user login
	$c->go( 'User', 'login' );
}


=head2 logout

Forward to the logout handler

=cut

sub logout : Path( 'logout' ) : Args( 0 ) {
	my ( $self, $c ) = @_;
	
	# Redirect to user logout
	$c->go( 'User', 'logout' );
}


=head2 search

Display search form, process submitted search forms.

=cut

sub search : Path('search') : Args(0) {
	my ( $self, $c ) = @_;
	
	$c->forward( 'Root', 'build_menu' );
	
	if ( $c->request->param( 'search' ) ) {
		$c->forward( 'Pages',      'search' );
		$c->forward( 'News',       'search' );
		$c->forward( 'Blog',       'search' );
		$c->forward( 'Forums',     'search' );
		$c->forward( 'Discussion', 'search' );
		$c->forward( 'Events',     'search' );
		# TODO: the rest ...
	}
}


=head2 sitemap

Generate a sitemap.

=cut

sub sitemap : Path('sitemap') : Args(0) {
	my ( $self, $c ) = @_;
	
	$c->forward( 'Root', 'build_menu' );
	
	my @sections = $c->model( 'DB::CmsSection' )->all;
	$c->stash->{ sections } = \@sections;
}


=head2 build_menu

Build the menu data structure.

=cut

sub build_menu : CaptureArgs(0) {
	my ( $self, $c ) = @_;
	
	# Build up menu structure for CMS pages
	$c->forward( 'Pages', 'build_menu' );
}


=head2 build_menu

Build the menu data structure.

=cut

sub switch_style : Path( 'switch-style' ) : Args( 1 ) {
	my ( $self, $c, $style ) = @_;
	
	$c->response->cookies->{ stylesheet } = { value => $style };
	
	$c->response->redirect( $c->uri_for( '/' ) );
	$c->response->redirect( $c->request->referer ) if $c->request->referer;
}


=head2 get_filenames

Get a list of filenames from a specified folder in the uploads area.

=cut

sub get_filenames {
	my ( $self, $c, $folder ) = @_;
	
	$folder ||= 'images';
	
	my $image_dir = $c->path_to( 'root', 'static', $c->config->{ upload_dir }, $folder );
	opendir( my $image_dh, $image_dir ) 
		or die "Failed to open image directory $image_dir: $!";
	
	my $images = [];
	foreach my $filename ( readdir( $image_dh ) ) {
		push @$images, $filename unless $filename =~ m/^\./; # skip hidden files
	}
	@$images = sort @$images;
	
	return $images;
}


=head2 default

404 handler

=cut

sub default : Path {
	my ( $self, $c ) = @_;
	
	$c->forward( 'Root', 'build_menu' );
	
	$c->stash->{ template } = '404.tt';
	
	$c->response->status(404);
}


=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass( 'RenderView' ) {
	my ( $self, $c ) = @_;
	
	# Override stylesheet based on prefs in cookie, if any
	my $override = $c->request->cookies->{ stylesheet }->value 
		if $c->request->cookies->{ stylesheet };
	$c->stash->{ head }->{ stylesheet } = $override || 'main';
}



=head1 AUTHOR

Denny de la Haye <2011@denny.me>

=head1 COPYRIGHT

ShinyCMS is copyright (c) 2009-2011 Shiny Ideas (www.shinyideas.co.uk).

=head1 LICENSE

This program is free software: you can redistribute it and/or modify it 
under the terms of the GNU Affero General Public License as published by 
the Free Software Foundation, either version 3 of the License, or (at your 
option) any later version.

You should have received a copy of the GNU Affero General Public License 
along with this program (see docs/AGPL-3.0.txt).  If not, see 
http://www.gnu.org/licenses/

=cut

__PACKAGE__->meta->make_immutable;

1;

