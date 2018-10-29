package App::Invoicer::Viewer;
use Moo; use v5.10;
use File::ShareDir 'dist_file';
use Mojo::Server::Daemon;

has daemon  => is => 'lazy';
has port    => is => 'ro',   default => sub{3000};
has url     => is => 'lazy', default => sub{'http://127.0.0.1:'. shift->port};
has invoice => is => 'ro';

sub run {
    my $self = shift;
    $self->daemon->app->invoice($self->invoice);

    say 'The invoice is ready at: ', $self->url;
    $self->daemon->run;
}

sub _app_file { dist_file('App-Invoicer', 'viewer/app.pl') }

sub _build_daemon {
    my $self   = shift;
    my $daemon = Mojo::Server::Daemon->new( listen => [$self->url], silent => 1 );

    my $app = $daemon->load_app( $self->_app_file );
    $app->log->level('error');

    $daemon;
}

1;
