#MIE-DSV. Distributed Systems and Computing.



##Implementation the PETERSON/DOLEV-KLAWE-RODEH election algorithm in distributed environment.



###Algorithm description

It is assumed that there are N processes (`N>1`) in a ring topology, connected by unbounded channels. A process can only send messages in a clockwise manner. Initially, each process has a unique identifier `ident`, below assumed to be a natural number. The purpose of a leader election algorithm is to make sure that exactly one process will become the **leader**. 

Algorithm was proposed by Dolev, Klawe and Rodeh in 1982. Initial state for a process is **active**. As long as a process is active it is responsible for a certain process number (kept in variable `d`). This value may change during time. 

When a process determines that it does not keep the identity of a leader-in-spe, it becomes **passive**. If a process is passive it passes messages from left to right in a transparent way, that is, without inspecting nor modifying their contents. 

Each active process sends its variable `d` to its clockwise neighbor, and then  waits until it receives the value `e` of its nearest active anti-clockwise neighbor. If the process receives its own `d`, it concludes that it is the only active process left  and that `d` is indeed the identity of the new leader, and terminates. 

In case a different value is received `e = d`, then the process waits for the second message `f` that contains the value `d` kept by the second nearest active anti-clockwise neighbor. If the value of the nearest active anti-clockwise neighbor is the largest among `e`, `f`, and `d`, then the process updates its local value (i.e. `d = e`), otherwise it becomes passive. Thus from every set of active neighbours one will become passive in every round. 

	Algorithm has assymptotical complexity O(NlogN) for the unidirectional ring.
	

###Algorithm implementation

Algorithm was developed in Perl programming language and based on inbuilt socket modules. Process is a standalone program which reserves a TCP Socket on a host. This sockets is used for message passing - receiving/sending data from/to other processes.

Processes are represented by script [node.pl] (https://github.com/platomik/mie-dsv/blob/master/node.pl "node.pl"). Started script reserves a free tcp socket and sets ID for itself (id is equal to socket number). 
	
	ID : 39564	//process at socket 39564 with uniqual identificator 39564.

Than standalone process starts expecting connection initialization. In order to build ring topology each process must have exactly one successor and one predecessor. Command prompt is waiting for connection establishment:

	connect to: 48153  // identificator of predecessor is 48153

When ring topology is built a 


###Usage


###Conclusions
