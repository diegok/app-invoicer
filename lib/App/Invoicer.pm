package App::Invoicer;
use Moo;
use CLI::Osprey;
use Mojo::File qw/ path /;

# ABSTRACT: Stop hating the end of month!

binmode(STDOUT, ":utf8");

has root_dir => is => 'lazy', default => sub{ path( shift->directory )->make_path };

option directory => (
    is      => 'ro',
    format  => 's',
    doc     => 'Folder to store your invoices (~/invoices)',
    default => sub{ "$ENV{HOME}/invoices" }
);

option tax_rate => (
    is      => 'ro',
    format  => 'i',
    doc     => 'Default tax rate (21%)',
    default => 21
);

subcommand create => 'App::Invoicer::cmd::create';
subcommand edit   => 'App::Invoicer::cmd::edit';
subcommand view   => 'App::Invoicer::cmd::view';
subcommand list   => 'App::Invoicer::cmd::list';

sub run { shift->osprey_help }

1;
