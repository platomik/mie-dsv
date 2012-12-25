#!/usr/bin/perl

use warnings;
use strict;

use IO::Socket::INET;
use IO::Select;

my $ioset = IO::Select->new;
my %socket_map;

my $debug = 1;
my $local_counter = 0;
my $global_counter = 0;
my $active = 1;
my $leader = 0; 

my @token = (0, 0, 0);
my @arrival = (0, 0);
sub new_conn {
    my ($port) = @_;
    return IO::Socket::INET->new(
        PeerAddr => 'localhost',
        PeerPort => $port
    ) || die "Unable to connect to $port: $!";
}

sub new_connection {
    my $server = shift;
    my $remote_port = shift;

    my $client = $server->accept;
    my $client_ip = client_ip($client);

#    print "Connection from $client_ip accepted.\n" if $debug;
#    print "\n" if $debug;
    
    my $remote = new_conn($remote_port);
    $ioset->add($client);
    $ioset->add($remote);

    $socket_map{$client} = $remote;
    $socket_map{$remote} = $client;
}

sub close_connection {
    my $client = shift;
    my $client_ip = client_ip($client);
    my $remote = $socket_map{$client};
    
    $ioset->remove($client);
    $ioset->remove($remote);

    delete $socket_map{$client};
    delete $socket_map{$remote};

    $client->close;
    $remote->close;

#    print "Connection from $client_ip closed.\n" if $debug;
    print "\n" if $debug;
}

sub client_ip {
    my $client = shift;
    return inet_ntoa($client->sockaddr);
}


#### start

my $remote_port;

my $server = IO::Socket::INET->new(
							        LocalAddr => 'localhost',
#							        LocalPort => $local_port,
							        ReuseAddr => 1,
							        Listen    => 100
								    ) || die "Could not create socket for local server: $!\n";

	my $local_port = $server->sockport();
	print "ID : $local_port\n";
	$token[0] = $local_port;
	
	print "connect to: ";
	while (<>) {
		chomp;
		if ($_ =~ /^(\d+)/) {$remote_port=$1; last;}
		print "connect to: ";
	}

$ioset->add($server);

while (1) {
    for my $socket ($ioset->can_read) {
        if ($socket == $server) {
            new_connection($server, $remote_port);
        }
        else {
            next unless exists $socket_map{$socket};
            my $remote = $socket_map{$socket};
            my $buffer;
            my $read = $socket->sysread($buffer, 4096);
            if ($read) {
		            	if ($buffer =~ /^ping/) {
		            			print "Start election procedure\n";
		            			$buffer = $local_port;
		            	}elsif($buffer =~/^Leader/){
		            			print $buffer,"\n";
	  			                if ($leader != 0) {sleep 3600;}
		            	}else{      		
			            		$local_counter++;
			            		$global_counter++;
			               		if ($local_counter == 4) {$local_counter = 1;}
			               		
			               		if ($active == 1) {
			               			# active mode
					               		if ($local_counter == 3) {
					               			# checking phase 3
					               				if (($token[1] > $token[2]) and ($token[1] > $token[0])){
					               					$token[0] = $token[1];
					               					$buffer = $token[0];
					               				} elsif ($token[0] == $token[1]) {
					               					$active = 0;
					               					$leader = $token[0];
					               					print "I know a leader! It is $token[0]\n";
					               				}else {
					               					$active = 0;
					               					print "Become PASSIVE\n";
					               				}					               			
					               		} else {
					               			# transfering phasses 1-2	
						            			@arrival=split(' ',$buffer);
#						            			print "recv: ",$arrival[$local_counter-1],"\n";
						            			$token[$local_counter] = $arrival[$local_counter-1];
						            			$buffer="$token[0] $token[1]";
#						            			print "snd: ",$buffer,"\n";
					               		}
				 	            	print "Step: ",$local_counter,"/",$global_counter," [",$token[0],",",$token[1],",",$token[2],"]\n";
			               		} else { 
			               			# passive mode
			               		}
		            	}
								
            	sleep 2;
                if ($leader == 0) {
                	$remote->syswrite($buffer);
                }else{
                	$remote->syswrite("Leader was found. It is $leader. Election procedure is finished.");
                }
            }
            else {
                close_connection($socket);
            }
        }
    }
}