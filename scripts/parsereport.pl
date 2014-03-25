#!/usr/bin/perl

my(%samples);
my($sample);
while(<>) {
    # Find the beginning of next sample

    next unless /^Fetching/;

    ($document_length) = /^Fetching [^ ]*\/([^\/ ]+)/;

    while(<>) {
        last if /^Transfer rate/;
    }

    ($transfer_rate) = /[^\d]*([\d\.]+)/;

    print $transfer_rate . "\t" . $document_length . "\n";
}

# Output Format
#         Kb/sec
# 4KiB    6215.20
# 8KiB    
# 16KiB   
