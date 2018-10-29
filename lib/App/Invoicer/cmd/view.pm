package App::Invoicer::cmd::view;
use Moo; use v5.10;
use CLI::Osprey;
use App::Invoicer::Viewer;

has invoices => is => 'lazy', default => sub {
    App::Invoicer::Invoices->new( root => shift->parent_command->root_dir )
};

option number => (
    is       => 'ro',
    format   => 'i',
    doc      => 'Invoice number to display in your browser',
    required => 1
);

sub run {
    my $self = shift;
    my $invoice = $self->invoices->get( $self->number ) || return $self->missing;
    App::Invoicer::Viewer->new( invoice => $invoice )->run;
}

sub missing {
    say "Invoice not found."
}

1;