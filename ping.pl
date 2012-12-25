#!/usr/bin/perl
use IO::Socket; 
my $sock = new IO::Socket::INET ( 
									PeerAddr => 'localhost', 
									PeerPort => $ARGV[0],
									Proto => 'tcp', 
								); die "Could not create socket: $!\n" unless $sock; 

print $sock "ping\n";
close($sock);
