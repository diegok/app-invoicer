package App::Invoicer::cmd::remove;
use Moo; use v5.10;
use CLI::Osprey desc => 'Remove invoices, use with caution!';

has invoices => is => 'lazy', default => sub {
    App::Invoicer::Invoices->new( root => shift->parent_command->root_dir )
};

option number => (
    is       => 'ro',
    format   => 'i',
    doc      => 'Invoice number to display in your browser',
    required => 1
);

option force => (
    is       => 'ro',
    doc      => 'Allow to remove any invoice',
);

#TODO: add option to re-arrange next invoices when removing one on the middle.

sub run {
    my $self = shift;
    if ( $self->force || $self->is_last_invoice ) {
        my $invoice = $self->invoices->get( $self->number ) || return $self->missing;
        $invoice->delete;
        say "Gone!";
    }
    else {
        say "Provided invoice --number is not the last one. You should use --force to remove it!";
    }
}

sub missing {
    say "Invoice not found."
}

sub is_last_invoice {
    my $self = shift;
    !$self->invoices->get( $self->number + 1 );
}

1;
