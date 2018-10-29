#!/usr/bin/env perl
use Mojolicious::Lite;

app->attr( invoice => sub { die 'Need App::Invoicer::Invoice object!' } );

get '/' => sub {
    my $c = shift;
    $c->render(
        invoice  => app->invoice,
        template => 'invoice-static'
    );
};

app->start;
