use strict;
use warnings;
# ABSTRACT: proved the needed bits to be a HTML-Grabber
package MooseX::Role::HTML::Grabber;

use MooseX::Role::Parameterized;

use MooseX::AttributeShortcuts;
use MooseX::Types::Moose       qw{ Str Bool };

use namespace::clean -except => 'meta';

use HTML::Grabber;

# VERSION

parameter name => (is => 'ro', isa => Str, default => 'html_grabber' );
parameter method => (is => 'ro', isa => Str, default => 'content' );

# traits, if any, for our attributes
parameter traits => (
    traits  => ['Array'],
    is      => 'ro',
    isa     => 'ArrayRef[Str]',
    default => sub { [] },
    handles => { all_traits => 'elements' },
);

role {
    use Data::Dumper;
    local $Data::Dumper::Indent = 1;
    my $p = shift @_;

    my $name = $p->name;

    my $traits = [ Shortcuts, $p->all_traits ];
    my @defaults = (traits => $traits, is => 'rw', lazy_build => 1);

    ## generate our attribute & builder names... nicely sequential tho :)
    my $a = sub {             $name . '_' . shift @_ };
    my $b = sub { '_build_' . $name . '_' . shift @_ };

    has $a->('grabber') => (@defaults, isa => 'HTML::Grabber');

    # create the HTML::Grabber for this named role.
    method $b->('grabber') => sub {
        my $self = shift @_;
        my $method = $p->method;
        my $grabber = HTML::Grabber->new( html => $self->$method );
        return $grabber;
    }
};

1;
