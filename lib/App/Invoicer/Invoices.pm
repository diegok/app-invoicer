package App::Invoicer::Invoices;
use Moo; use v5.10;
use Mojo::File qw/ path /;
use App::Invoicer::Invoice;

has root     => is => 'ro', required => 1;
has root_dir => is => 'lazy', default => sub{ path( shift->root ) };
has current_year => is => 'lazy';

sub years {
    my $self = shift;
    $self->root_dir->list({ dir => 1 })
        ->grep(sub{ -d && $_->basename =~ /^\d+$/ })
        ->sort(sub{ $a->basename <=> $b->basename })
}

# Get current year directory
sub _build_current_year {
    my $self = shift;
    my $dir = $self->root_dir->child( (localtime)[5]+1900 );
    $dir->make_path; # Ensure it exists
    $dir;
}

sub files {
    my ( $self, $year ) = @_;
    my $years = $self->years;
    $years = $years->grep(qr/$year/) if $year;
    $years->map(sub{ $_->list })->flatten;
}

sub list {
    my ( $self, %opt ) = @_;
    $self->files( $opt{year} )->map(sub{
        App::Invoicer::Invoice->new( file => $_)
    })->grep(sub{
        return if $opt{quarter} && $_->quarter ne $opt{quarter};
        return if $opt{month}   && $_->date->month ne $opt{month};
        return if $opt{customer} && !(
            $_->customer->name =~ /\Q$opt{customer}\E/i
            ||
            $_->customer->tax_id =~ /\Q$opt{customer}\E/i
        );
        1;
    });
}

sub get {
    my ( $self, $number ) = @_;
    my $basename = "$number.json";
    for my $year ( $self->years->reverse->each ) {
        my $file = $year->child($basename);
        return App::Invoicer::Invoice->new( file => $file ) if -f $file;
    }
}

sub create {
    my $self = shift;
    # TODO: accept year and number to create old invoices (must check it's coherent)

    App::Invoicer::Invoice->new(
        file => $self->current_year->child( $self->next_number .'.json' )
    );
}

sub next_number {
    my $self = shift;

    for my $year ( $self->years->reverse->each ) {
        my $last = $year->list->map(sub{
            /(\d+)\.json/ && $1
        })->sort(sub{
            $b <=> $a
        })->first;

        return $last + 1 if $last;
    }

    1; # yay, first invoice!
}

1;
