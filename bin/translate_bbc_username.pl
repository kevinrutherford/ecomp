#!/usr/bin/perl

$author = $ARGV[0];

$author =~ m|/emailAddress=([^@]+)@([^/]+)/|;

$name = $1;
$emailAddress = $1 . '@' . $2;

$name =~ s/\./ /g;

print "$name <$emailAddress>\n";

