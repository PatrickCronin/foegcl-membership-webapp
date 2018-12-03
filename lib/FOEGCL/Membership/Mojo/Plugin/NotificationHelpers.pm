package FOEGCL::Membership::Mojo::Plugin::NotificationHelpers;

use FOEGCL::Membership::Moose::Mojo;
extends 'Mojolicious::Plugin';

use Const::Fast 'const';

const my $FLASH   => 'flash';
const my $STASH   => 'stash';
const my $ERROR   => 'error';
const my $WARNING => 'warning';
const my $INFO    => 'info';
const my $SUCCESS => 'success';

sub register ( $self, $app, @ ) {
    $app->helper( add_flash_error   => sub { _add_flash_error(@_) } );
    $app->helper( add_flash_warning => sub { _add_flash_warning(@_) } );
    $app->helper( add_flash_info    => sub { _add_flash_info(@_) } );
    $app->helper( add_flash_success => sub { _add_flash_success(@_) } );
    $app->helper( add_stash_error   => sub { _add_stash_error(@_) } );
    $app->helper( add_stash_warning => sub { _add_stash_warning(@_) } );
    $app->helper( add_stash_info    => sub { _add_stash_info(@_) } );
    $app->helper( add_stash_success => sub { _add_stash_success(@_) } );
}

sub _add_flash_error ( $c, $text, @ ) {
    _add_notification( $c, $FLASH, $ERROR, $text );
}

sub _add_flash_warning ( $c, $text, @ ) {
    _add_notification( $c, $FLASH, $WARNING, $text );
}

sub _add_flash_info ( $c, $text, @ ) {
    _add_notification( $c, $FLASH, $INFO, $text );
}

sub _add_flash_success ( $c, $text, @ ) {
    _add_notification( $c, $FLASH, $SUCCESS, $text );
}

sub _add_stash_error ( $c, $text, @ ) {
    _add_notification( $c, $STASH, $ERROR, $text );
}

sub _add_stash_warning ( $c, $text, @ ) {
    _add_notification( $c, $STASH, $WARNING, $text );
}

sub _add_stash_info ( $c, $text, @ ) {
    _add_notification( $c, $STASH, $INFO, $text );
}

sub _add_stash_success ( $c, $text, @ ) {
    _add_notification( $c, $STASH, $SUCCESS, $text );
}

sub _add_notification ( $c, $target, $type, $text ) {
    if ( $target eq $FLASH ) {
        my $current = $c->flash($type);
        if ( defined $current ) {
            push $c->flash($type)->@*, $text;
        }
        else {
            $c->flash( $type, [$text] );
        }
    }
    elsif ( $target eq $STASH ) {
        my $current = $c->stash($type);
        if ( defined $current ) {
            push $c->stash($type)->@*, $text;
        }
        else {
            $c->stash( $type, [$text] );
        }
    }
}

__PACKAGE__->meta->make_immutable;

1;
