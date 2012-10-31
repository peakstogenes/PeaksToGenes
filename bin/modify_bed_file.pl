#!/usr/bin/env perl 

use strict;
use warnings;
use utf8;

my $bed_file = $ARGV[0];

open my $file, "<", $bed_file or die "Could not read from $bed_file $!\n";
while (<$file>) {
	my $line = $_;
	chomp ($line);

	my @line_items = split(/\t/, $line);

	if ( @line_items == 6 ) {
		print join("\t", $line_items[0], $line_items[1], $line_items[2],
			$line_items[3], $line_items[4]), "\n";
	}
}
