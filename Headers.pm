package Tags::HTML::HTTP::Headers;

use parent 'Tags::HTML';
use strict;
use warnings;

use Class::Utils qw(set_params);
use Error::Pure qw(err);
use List::Util qw(any);
use Readonly;
use Scalar::Util qw(blessed);

Readonly::Hash our %TYPES => (
	'cache' => [
		'Cache-Control',
		'ETag',
		'Expires',
		'If-Match',
		'If-Modified-Since',
		'If-None-Match',
		'If-Unmodified-Since',
		'Last-Modified',
		'Pragma',
		'Vary',
	],
	'control' => [
		'Content-Encoding',
		'Content-Language',
		'Content-Length',
		'Content-Location',
		'Content-MD5',
		'Content-Range',
		'Content-Type',
	],
	'login' => [
		'Authorization',
		'Cookie',
		'Proxy-Authorization',
		'Proxy-Authenticate',
		'Set-Cookie',
		'WWW-Authenticate',
	],
);
Readonly::Hash our %COLORS => (
	'cache' => 'bisque',
	'control' => 'turquoise',
	'login' => 'indigo',
);

our $VERSION = 0.01;

sub _cleanup {
	my ($self, $env) = @_;

	delete $self->{'_headers'};

	return;
}

sub _find_color {
	my ($self, $header_key) = @_;

	my $color = 'black';
	foreach my $type_group (keys %TYPES) {
		if (any { $header_key eq $_ } @{$TYPES{$type_group}}) {
			$color = $COLORS{$type_group};
		}
	}

	return $color;
}

sub _init {
	my ($self, $headers) = @_;

	if (! defined $headers
		|| ! blessed($headers)
		|| ! $headers->isa('HTTP::Headers')) {

		err "Object must be a 'HTTP::Headers' object.";
	}

	$self->{'_headers'} = $headers;

	return;
}

sub _process {
	my $self = shift;

	my %headers;
	if (ref $self->{'_headers'} eq 'HTTP::Headers::Fast') {
		%headers = @{$self->{'_headers'}->psgi_flatten};
	} else {
		%headers = $self->{'_headers'}->flatten;
	}
	$self->{'tags'}->put(
		['b', 'div'],
		['a', 'class', 'headers'],
	);
	foreach my $header_key (keys %headers) {
		my $color = $self->_find_color($header_key);
		$self->{'tags'}->put(
			['b', 'span'],
			['a', 'style', 'color: '.$color.';'],
			['d', $header_key],
			['e', 'span'],
			['d', ':'],
			['b', 'span'],
			['d', $headers{$header_key}],
			['e', 'span'],
			['b', 'br'],
			['e', 'br'],
		);
	}
	$self->{'tags'}->put(
		['e', 'div'],
	);

	return;
}

sub _process_css {
	my $self = shift;

	return;
}

1;

__END__

=pod

=encoding utf8

=head1 NAME

Tags::HTML::HTTP::Headers - Tags helper for gradient evaluation.

=head1 SYNOPSIS

 use Tags::HTML::HTTP::Headers;

 my $obj = Tags::HTML::HTTP::Headers->new(%params);
 $obj->process($stars_hr);
 $obj->process_css;

=head1 METHODS

=head2 C<new>

 my $obj = Tags::HTML::HTTP::Headers->new(%params);

Constructor.

=over 8

=item * C<css>

'CSS::Struct::Output' object for L<process_css> processing.

It's required.

Default value is undef.

=item * C<css_background_image>

CSS parameter for background-image of gradient.

Default value is 'linear-gradient(to right, red, orange, yellow, green, blue, indigo, violet)'.

=item * C<css_gradient_class>

CSS class name for gradient.

Default value is 'gradient'.

=item * C<height>

Indicator height.

Default value is 30.

=item * C<unit>

Unit for height and width.

Default value is 'px'.

=item * C<width>

Indicator width.

Default value is 500.

=item * C<tags>

'Tags::Output' object.

Default value is undef.

=back

=head2 C<process>

 $obj->process($percent_value);

Process Tags structure for gradient.

Returns undef.

=head2 C<process_css>

 $obj->process_css;

Process CSS::Struct structure for output.

Returns undef.

=head1 ERRORS

 new():
         From Class::Utils::set_params():
                 Unknown parameter '%s'.
         Parameter 'css' must be a 'CSS::Struct::Output::*' class.
         Parameter 'tags' must be a 'Tags::Output::*' class.

=head1 EXAMPLE1

 use strict;
 use warnings;

 use CSS::Struct::Output::Indent;
 use Tags::HTML::HTTP::Headers;
 use Tags::Output::Indent;

 # Object.
 my $css = CSS::Struct::Output::Indent->new;
 my $tags = Tags::Output::Indent->new;
 my $obj = Tags::HTML::HTTP::Headers->new(
         'css' => $css,
         'tags' => $tags,
 );

 # Process indicator.
 $obj->process_css;
 $obj->process(50);

 # Print out.
 print "CSS\n";
 print $css->flush."\n";
 print "HTML\n";
 print $tags->flush."\n";

 # Output:
 # CSS
 # .gradient {
 #         height: 30px;
 #         width: 500px;
 #         background-color: red;
 #         background-image: linear-gradient(to right, red, orange, yellow, green, blue, indigo, violet);
 # }
 # HTML
 # <div style="width: 250px;overflow: hidden;">
 #   <div class="gradient">
 #   </div>
 # </div>

=head1 EXAMPLE2

 use strict;
 use warnings;

 use CSS::Struct::Output::Indent;
 use Tags::HTML::HTTP::Headers;
 use Tags::Output::Indent;

 if (@ARGV < 1) {
         print STDERR "Usage: $0 percent\n";
         exit 1;
 }
 my $percent = $ARGV[0];

 # Object.
 my $css = CSS::Struct::Output::Indent->new;
 my $tags = Tags::Output::Indent->new;
 my $obj = Tags::HTML::HTTP::Headers->new(
         'css' => $css,
         'tags' => $tags,
 );

 # Process indicator.
 $obj->process_css;
 $obj->process($percent);

 # Print out.
 print "CSS\n";
 print $css->flush."\n";
 print "HTML\n";
 print $tags->flush."\n";

 # Output:
 # TODO

=head1 DEPENDENCIES

L<Class::Utils>,
L<Error::Pure>.

=head1 SEE ALSO

=over

=item L<Tags::HTML::Stars>

Tags helper for stars evaluation.

=back

=head1 REPOSITORY

L<https://github.com/michal-josef-spacek/Tags-HTML-HTTP-Headers>

=head1 AUTHOR

Michal Josef Špaček L<mailto:skim@cpan.org>

L<http://skim.cz>

=head1 LICENSE AND COPYRIGHT

© Michal Josef Špaček 2024

BSD 2-Clause License

=head1 VERSION

0.01

=cut
