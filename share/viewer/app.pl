#!/usr/bin/env perl
use Mojolicious::Lite;

app->attr( invoice  => sub { die 'Need App::Invoicer::Invoice object!' } );
app->attr( invoices => sub { die 'Need App::Invoicer::Invoices object!' } );

get '/' => sub {
    my $c = shift;
    $c->redirect_to( view => number => app->invoice->number );
};

under '/:number' => sub {
    my $c = shift;

    if ( my $invoice = app->invoices->get( $c->stash('number') ) ) {
        return $c->stash( invoice => $invoice );
    }

    $c->reply->not_found; 0;
};

get '/' => sub {
    my $c = shift;
    $c->render(
        invoice  => $c->stash('invoice'),
        template => 'invoice-static'
    );
} => 'view';

app->start;
