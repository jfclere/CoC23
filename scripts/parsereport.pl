#!/usr/bin/perl

my(%samples);
my($sample);
while(<>) {
    # Find the beginning of next sample

    next unless /^Fetching/;

    ($document_length) = /^Fetching [^ ]*\/([^\/ ]+)/;

    while(<>) {
        last if /^Transfer rate/;
        last if /^finished in/;
    }

    if (/^Transfer rate/) {
        ($transfer_rate) = /[^\d]*([\d\.]+)/;
    } else {
        # h2load gives "finished in 539.99ms, 18519 req/s, 198.94MB/s"
        if (/MB/s) {
            my @fields = split(/, /);
            ($transfer_rate) = $fields[2] =~ /[^\d]*([\d\.]+)/;
            $transfer_rate = $transfer_rate * 1000;
        }
        if (/KB/s) {
            my @fields = split(/, /);
            ($transfer_rate) = $fields[2] =~ /[^\d]*([\d\.]+)/;
        }
    }

    print $transfer_rate . "\t" . $document_length . "\n";
}

# Output Format
#         Kb/sec
# 4KiB    6215.20
# 8KiB    
# 16KiB   
