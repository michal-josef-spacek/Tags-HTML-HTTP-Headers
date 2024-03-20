package Tags::HTML::HTTP::Headers;

use parent qw(Tags::HTML);
use strict;
use warnings;

use Class::Utils qw(set_params);
use Error::Pure qw(err);
use List::Util qw(any);
use Readonly;
use Scalar::Util qw(blessed);

Readonly::Array our @TYPES => ('cache', 'client_info', 'connection', 'control', 'login',
	'negotiation', 'proxy', 'security', '');
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
	'client_info' => [
		'DNT',
		'From',
		'Referer',
		'User-Agent',
		'X-Forwarded-For',
		'X-Forwarded-Host',
		'X-Forwarded-Proto',
		'X-Requested-With',
	],
	'connection' => [
		'Connection',
		'Host',
		'Keep-Alive',
		'TE',
		'Transfer-Encoding',
		'Upgrade',
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
	'negotiation' => [
		'Accept',
		'Accept-Language',
		'Accept-Encoding',
		'Purpose',
	],
	'proxy' => [
		'X-Forwarded-Port',
		'X-Forwarded-Ssl',
		'X-Original-Uri',
		'X-Real-Ip',
	],
	'security' => [
		'Content-Security-Policy',
		'Cross-Origin-Embedder-Policy',
		'Cross-Origin-Opener-Policy',
		'Cross-Origin-Resource-Policy',
		'Feature-Policy',
		'Permissions-Policy',
		'Referrer-Policy',
		'Sec-Ch-Ua',
		'Sec-Ch-Ua-Platform',
		'Sec-Ch-Ua-Mobile',
		'Sec-Fetch-Dest',
		'Sec-Fetch-Mode',
		'Sec-Fetch-Site',
		'Sec-Fetch-User',
		'Sec-Purpose',
		'Sec-WebSocket-Key',
		'Strict-Transport-Security',
		'Upgrade-Insecure-Requests',
		'X-Content-Type-Options',
		'X-Frame-Options',
		'X-XSS-Protection',
	],
);
Readonly::Hash our %COLORS => (
	'cache' => 'sandybrown',
	'client_info' => 'fuchsia',
	'connection' => 'chartreuse',
	'control' => 'turquoise',
	'login' => 'indigo',
	'negotiation' => 'darkturquoise',
	'proxy' => 'plum',
	'security' => 'darkgreen',
);

our $VERSION = 0.01;

sub _cleanup {
	my ($self, $env) = @_;

	delete $self->{'_headers'};

	return;
}

sub _headers {
	my $self = shift;

	my %headers;
	if (ref $self->{'_headers'} eq 'HTTP::Headers::Fast') {
		%headers = @{$self->{'_headers'}->psgi_flatten};
	} else {
		%headers = $self->{'_headers'}->flatten;
	}

	my $ret_headers_hr = {};
	foreach my $header_key (sort keys %headers) {
		my $none = 1;
		foreach my $type_group (keys %TYPES) {
			if (any { $header_key eq $_ } @{$TYPES{$type_group}}) {
				if (! exists $ret_headers_hr->{$type_group}) {
					$ret_headers_hr->{$type_group} = [];
				}
				push @{$ret_headers_hr->{$type_group}},
					[$header_key, $headers{$header_key}];
				$none = 0;
				last;
			}
		}
		if ($none) {
			push @{$ret_headers_hr->{''}},
				[$header_key, $headers{$header_key}];
		}
	}

	return $ret_headers_hr;
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

	$self->{'tags'}->put(
		['b', 'div'],
		['a', 'class', 'headers'],
	);
	my $headers_hr = $self->_headers;
	foreach my $type (@TYPES) {
		my $color = 'black';
		if (exists $COLORS{$type}) {
			$color = $COLORS{$type};
		}
		foreach my $header_ar (@{$headers_hr->{$type}}) {
			$self->{'tags'}->put(
				['b', 'div'],
				['a', 'class', 'header-item'],

				['b', 'span'],
				['a', 'class', 'key'],
				['a', 'style', 'color: '.$color.';'],
				['d', $header_ar->[0]],
				['e', 'span'],
				['d', ':'],
				['b', 'span'],
				['a', 'class', 'value'],
				['d', $header_ar->[1]],
				['e', 'span'],

				['e', 'div'],
			);
		}
	}
	$self->{'tags'}->put(
		['e', 'div'],
	);

	return;
}

sub _process_css {
	my $self = shift;

	$self->{'css'}->put(
		['s', '.headers'],
		['d', 'margin', '1em'],
		['d', 'padding', '1em'],
		['d', 'border-radius', '8px'],
		['d', 'box-shadow', '0 2px 4px rgba(0, 0, 0, 0.1)'],
		['d', 'background-color', '#f4f4f4'],
		['e'],

		['s', '.header-item'],
		['d', 'margin-bottom', '0.5em'],
		['e'],

		['s', '.key'],
		['d', 'font-weight', 'bold'],
		['d', 'color', '#333'],
		['e'],

		['s', '.value'],
		['d', 'margin-left', '0.5em'],
		['e'],
	);

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
 $obj->cleanup;
 $obj->init($headers);
 $obj->process;
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

=item * C<tags>

'Tags::Output' object.

Default value is undef.

=back

Returns instance of object.

=head2 C<cleanup>

 $obj->cleanup;

Process cleanup after page run.

In this case cleanup internal representation of a set by L<init>.

Returns undef.

=head2 C<init>

 $obj->init($headers);

Process initialization in page run.

Accepted C<$headers> is L<HTTP::Headers> object.

There is difference in C<flatten()> method of L<HTTP::Headers> and
C<psgi_flatten()> method of L<HTTP::Headers::Fast>. Second one is accepted too.

Returns undef.

=head2 C<process>

 $obj->process;

Process Tags structure for HTTP headers.

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

=head1 EXAMPLE

=for comment filename=create_headers_and_print.pl

 use strict;
 use warnings;

 use CSS::Struct::Output::Indent;
 use HTTP::Headers;
 use Tags::HTML::HTTP::Headers;
 use Tags::Output::Indent;

 # Object.
 my $css = CSS::Struct::Output::Indent->new;
 my $tags = Tags::Output::Indent->new;
 my $obj = Tags::HTML::HTTP::Headers->new(
         'css' => $css,
         'tags' => $tags,
 );

 # Example Header.
 my $headers = HTTP::Headers->new(
         'Host' => 'example.com',
         'Content-Type' => 'text/plain',
 );

 # Init.
 $obj->init($headers);

 # Process HTTP::Headers.
 $obj->process_css;
 $obj->process;

 # Print out.
 print "CSS\n";
 print $css->flush."\n";
 print "HTML\n";
 print $tags->flush."\n";

 # Output:
 # CSS
 # .headers {
 #         margin: 1em;
 #         padding: 1em;
 #         border-radius: 8px;
 #         box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
 #         background-color: #f4f4f4;
 # }
 # HTML
 # <div class="headers">
 #   <span style="color: chartreuse;">
 #     Host
 #   </span>
 #   :
 #   <span>
 #     example.com
 #   </span>
 #   <br>
 #   </br>
 #   <span style="color: turquoise;">
 #     Content-Type
 #   </span>
 #   :
 #   <span>
 #     text/plain
 #   </span>
 # </div>

=head1 DEPENDENCIES

L<Class::Utils>,
L<Error::Pure>.
L<List::Util>,
L<Readonly>,
L<Scalar::Util>,
L<Tags::HTML>.

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
