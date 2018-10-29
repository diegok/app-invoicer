package App::Invoicer::cmd::edit;

use Moo; use v5.10;
use CLI::Osprey desc => 'Edit stored invoice on your';

has invoices => is => 'lazy', default => sub {
    App::Invoicer::Invoices->new( root => shift->parent_command->root_dir )
};

option number => (
    is       => 'ro',
    required => 1,
    format   => 'i',
    doc      => 'Number of invoice you want to edit',
);

sub run {
    my $self = shift;
    my $invoice = $self->invoices->get( $self->number ) || return $self->missing;
    chomp( my $editor = $ENV{EDITOR} || `which vim` );
    system( $editor => $invoice->file );

    my $edited = $self->invoices->get( $self->number );

    if ( !$edited->has_data ) {
        say 'Missing basic data, aborted.';
        $invoice->save;
    }
    elsif ( $edited->number != $self->number ) {
        say 'Number has changed, aborted.';
        $invoice->save;
    }
    else {
        say 'Done.'; # TODO: show what changed?
    }
}

sub missing {
    say "Invoice not found."
}

1;
