package App::Invoicer::cmd::list;
use Moo; use v5.10;
use CLI::Osprey desc => 'List, filter and summarize stored invoices';
use App::Invoicer::Invoices;
use Mojo::Util qw/ tablify /;

has invoices => is => 'lazy', default => sub {
    App::Invoicer::Invoices->new( root => shift->parent_command->root_dir )
};

option summary => (
    is      => 'ro',
    doc     => 'Display a summary of listed invoices',
);

option year => (
    is      => 'ro',
    format  => 'i',
    doc     => 'Invoices on this year',
);

option month => (
    is      => 'ro',
    format  => 'i',
    doc     => 'Invoices in this month number',
);

option quarter => (
    is      => 'ro',
    format  => 'i',
    doc     => 'Invoices in this quarter',
);

option customer => (
    is      => 'ro',
    format  => 's',
    doc     => 'Invoices where customer name or tax-id match',
);

sub run {
    my $self = shift;

    my $summary = {};

    my $data = $self->invoices->list(
        map { $_ => $self->$_||'' } qw/ year month quarter customer /
    )->each(sub{
        $summary->{count}++;
        $summary->{customers}{$_->customer->tax_id}++;
        $summary->{subtotal} += $_->subtotal;
        $summary->{total}    += $_->total;
        $summary->{tax}      += $_->tax;
    })->map(sub{[
        $_->number,
        $_->date,
        $_->customer->name,
        sprintf('%.2f', $_->subtotal),
        sprintf('%.2f', $_->total)
    ]})->to_array;

    say tablify([ [qw/ Number Date Customer Subtotal Total /], [], @$data ]);

    if ( $self->summary && $summary->{count} ) {
        say (('>' x15). ' Summary ' .('<' x15));
        say tablify([ [qw/ Invoices Customers Subtotal Tax Total /], [
            $summary->{count},
            scalar(keys %{$summary->{customers}||{}}),
            map { sprintf('%.2f', $summary->{$_}) } qw/ subtotal tax total /
        ]]);
    }
}

1;
