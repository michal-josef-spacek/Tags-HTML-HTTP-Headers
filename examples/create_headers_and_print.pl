#!/usr/bin/env perl

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