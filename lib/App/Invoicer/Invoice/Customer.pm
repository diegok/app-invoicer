package App::Invoicer::Invoice::Customer;
use Moo;

has name    => is => 'rw', default => sub{''};
has tax_id  => is => 'rw', default => sub{''};
has address => is => 'rw', default => sub{['','']};

sub to_hash {
    my $self = shift;
    return { map { $_ => $self->$_ } qw/ name address tax_id / };
}

1;
