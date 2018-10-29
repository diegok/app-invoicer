# App::Invoicer

This is my personal CLI for invoicing. At the moment it's fully functional for myself and I'm working towards a customizable version which allows anyone to use it.

## Main features

This is an incomplete list of features. This is mostly what I like from this tool:

- Invoices are just JSON on my disk (defaults to `$HOME/invoices/[year]/[number].json`)
- Invoices are edited in my $EDITOR (vim when not set)
- It handles numbers and dates automatically on creation
- You can create a new invoice from a previous one just passing some part of the customer name
- You can list and filter issued invoices and even get a summary
- Invoices are displayed on your browser for printing. Invoice template is just an HTML.

## Installing

This is a perl project and at some point I will upload it to CPAN to allow easier installation. At this moment, you need to manually install Dist::Zilla and then:

> dzil install

Once installed, you can get a list of sub-commands just running `invoicer` and help on every subcommand using --help.

## TODO

This is what future versions will probably implement:

- Add generic invoice template and allow to customize and keep it with invoice definitions.
- Improve list --summary to make it trivial to handle bureaucracy.
- Add flags to invoices to improve list filtering (mark invoices already paid)
- CSV output of listed invoices
- Git support to keep track of invoice changes
- Improve docs

## Interested?

If you like it, feel free to use it, fork-it and if you implement anything useful, I will love to accept pull-requests.
