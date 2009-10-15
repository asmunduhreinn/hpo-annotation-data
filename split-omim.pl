#!/usr/bin/perl

$hdr = <>;
while (<>) {
    @fields = split(/t/);
    my $omim = $fields[0];
    if ($omim =~ /^MIM:(\d+)/) {
        my $f = "MIM-$1.tab";
        if ($done{$f}) {
            #print STDERR "appending: $f\n";
            open(F,">>","$f");
        }
        else {
            open(F,">$f");
            print F $hdr;
            $done{$f} = 1;
        }
        print F $_;
        close(F);
    }
}
