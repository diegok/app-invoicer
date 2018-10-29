package App::Invoicer::Invoice;

use Moo;
use App::Invoicer::Invoice::Customer;
use Date::Tiny;
use List::Util qw/ sum0 /;
use JSON qw/ decode_json /;

has file    => is => 'ro', required => 1; # must be a Mojo::File object
has source  => is => 'lazy', clearer => 1;

has number => is => 'lazy', clearer => 1, default => sub{
    $_[0]->source->{number} || $_[0]->_number_from_filename
};

has items  => is => 'lazy', clearer => 1, default => sub{
    shift->source->{items} || [_empty_item()]
};

has tax_rate => is => 'lazy', clearer => 1, default => sub{
    $_[0]->source->{tax_rate} || $_[0]->source->{taxed} || 21
};

has date =>
    is      => 'lazy',
    clearer => 1,
    coerce  => sub{ ref $_[0] ? $_[0] : _parsedate($_[0]) },
    default => sub{
        my $str = shift->source->{date};
        $str ? _parsedate( $str ) : Date::Tiny->now;
    };

has customer =>
    is      => 'lazy',
    clearer => 1,
    coerce  => sub {
        ref $_[0] eq 'HASH' ? App::Invoicer::Invoice::Customer->new($_[0]) : $_[0]
    },
    default => sub{
        App::Invoicer::Invoice::Customer->new( shift->source->{customer} ||{} );
    };

sub to_hash {
    my $self = shift;
    +{
        date => sprintf('%d-%02d-%02d', map { $self->date->$_ } qw/ year month day / ),
        customer => $self->customer->to_hash,
        map { $_ => $self->$_ } qw/ number items tax_rate /
    };
}

sub save {
    my $self = shift;
    $self->file->spurt( JSON->new->pretty(1)->encode( $self->to_hash ) );
    $self;
}

sub delete {
    my $self = shift;
    unlink $self->file;
}

# Just clear everything and let lazy loading do it's stuff.
sub reload {
    my $self = shift;
    $self->$_ for map {"clear_$_"} qw/ number items tax_rate date customer source /;
    $self;
}

sub quarter { ( map { ($_)x3 } 1..4 )[ shift->date->month - 1 ] }

sub has_data {
    my $self = shift;
    $self->has_customer && $self->has_items;
}

sub has_customer { shift->customer->name }

sub has_items {
    my $self = shift;
    $self->items && $self->items->[0] && $self->items->[0]{description};
}

sub _empty_item {{ description => '', price => 0 }}

sub _parsedate {
    my $str = pop;

    if ( $str =~ m|^ \s* (\d+) [-/] (\d+) [-/] (\d+) \s* $|x ) {
        my ( $year, $month, $day ) = $1 > 31 ? ( $1, $2, $3 ) : ( $3, $2, $1 );
        return Date::Tiny->new(
            year  => $year,
            month => $month,
            day   => $day
        );
    }

    say("Unable to parse a date from '$str'.") && exit;
}

sub date_string {
    my $self = shift;
    my $dt = $self->date;
    my $m  = [qw/
        Enero Febrero Marzo Abríl Mayo Junio Julio Agosto
        Septiembre Octubre Noviembre Diciembre
    /];
    sprintf('%d de %s, %d', $dt->day, $m->[$dt->month-1], $dt->year);
}

sub subtotal {
    my $self = shift;
    sum0( map { $_->{price} || 0 } @{$self->items} );
}

sub tax {
    my $self = shift;
    ($self->subtotal * $self->tax_rate) / 100;
}

sub total {
    my $self = shift;
    $self->subtotal + $self->tax;
}

sub is_stored { -f shift->file }

sub _build_source {
    my $self = shift;
    return {} unless $self->is_stored;
    decode_json( $self->file->slurp );
}

sub _number_from_filename {
    my $self = shift;
    my ($id) = $self->file =~ /(\d+)\.json$/;
    return $id;
}

1;

