package Catalyst::Plugin::Session::State::Cookie;
use base qw/Catalyst::Plugin::Session::State/;

use strict;
use warnings;

use NEXT;

our $VERSION = "0.01";

sub setup_session {
    my $c = shift;

    $c->NEXT::setup_session(@_);

    $c->config->{session}{cookie_name} ||= "session";
}

sub finalize_cookies {
    my $c = shift;

    if ( $c->sessionid ) {
        $c->update_session_cookie( $c->make_session_cookie );
    }

    return $c->NEXT::finalize_cookies(@_);
}

sub update_session_cookie {
    my ( $c, $updated ) = @_;
    my $cookie_name = $c->config->{session}{cookie_name};
    $c->response->cookies->{$cookie_name} = $updated;
}

sub make_session_cookie {
    my $c = shift;

    my $cfg    = $c->config->{session};
    my $cookie = {
        value => $c->sessionid,
        ( $cfg->{cookie_domain} ? ( domain => $cfg->{cookie_domain} ) : () ),
    };

    if ( exists $cfg->{cookie_expires} ) {
        if ( my $ttl = $cfg->{cookie_expires} ) {
            $cookie->{expires} = time() + $ttl;
        }    # else { cookie is non-persistent }
    }
    else {
        $cookie->{expires} = $c->session->{__expires};
    }

    return $cookie;
}

sub prepare_cookies {
    my $c = shift;

    my $ret = $c->NEXT::prepare_cookies(@_);

    my $cookie_name = $c->config->{session}{cookie_name};

    if ( my $cookie = $c->request->cookies->{$cookie_name} ) {
        my $sid = $cookie->value;
        $c->sessionid($sid);
        $c->log->debug(qq/Found sessionid "$sid" in cookie/) if $c->debug;
    }

    return $ret;
}

__PACKAGE__

__END__

=pod

=head1 NAME

Catalyst::Plugin::Session::State::Cookie - A session ID 

=head1 SYNOPSIS

    use Catalyst qw/Session Session::State::Cookie Session::Store::Foo/;

=head1 DESCRIPTION

In order for L<Catalyst::Plugin::Session> to work the session ID needs to be
stored on the client, and the session data needs to be stored on the server.

This plugin stores the session ID on the client using the cookie mechanism.

=head1 METHODS

=over 4

=item make_session_cookie

Returns a hash reference with the default values for new cookies.

=item update_session_cookie $hash_ref

Sets the cookie based on C<cookie_name> in the response object.

=back

=head1 EXTENDED METHODS

=over 4

=item prepare_cookies

Will restore if an appropriate cookie is found.

=item finalize_cookies

Will set a cookie called C<session> if it doesn't exist or if it's value is not
the current session id.

=item setup_session

Will set the C<cookie_name> parameter to it's default value if it isn't set.

=back

=head1 CONFIGURATION

=over 4

=item cookie_name

The name of the cookie to store (defaults to C<session>).

=item cookie_domain

The name of the domain to store in the cookie (defaults to current host)

=back

=head1 CAVEATS

Sessions have to be created before the first write to be saved. For example:

	sub action : Local {
		my ( $self, $c ) = @_;
		$c->res->write("foo");
		$c->session( ... );
		...
	}

Will cause a session ID to not be set, because by the time a session is
actually created the headers have already been sent to the client.

=head1 SEE ALSO

L<Catalyst>, L<Catalyst::Plugin::Session>.

=head1 AUTHORS

This module is derived from L<Catalyst::Plugin::Session::FastMmap> code, and
has been heavily modified since.

Andrew Ford
Andy Grundman
Christian Hansen
Yuval Kogman, C<nothingmuch@woobling.org>
Marcus Ramberg
Sebastian Riedel

=head1 COPYRIGHT

This program is free software, you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
