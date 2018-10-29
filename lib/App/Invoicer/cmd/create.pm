package App::Invoicer::cmd::create;
use Moo; use v5.10;
use CLI::Osprey desc => 'Create a new invoice';

has invoices => is => 'lazy', default => sub {
    App::Invoicer::Invoices->new( root => shift->parent_command->root_dir )
};

option customer => (
    is      => 'ro',
    format  => 's',
    doc     => 'Customer name or part if it`s name to auto-fill new invoice',
);

sub run {
    my $self = shift;
    my $invoice = $self->invoices->create->save;
    chomp( my $editor = $ENV{EDITOR} || `which vim` );
    system( $editor => $invoice->file );
    unless ( $invoice->reload->has_data ) {
        say 'Incomplete invoice, aborted.';
        $invoice->delete;
    }
}

1;
