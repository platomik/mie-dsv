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

When ring topology is built an election procedure can be started. Script [ping.pl] (https://github.com/platomik/mie-dsv/blob/master/ping.pl "ping.pl") is used for initialization election. Script 'pings' a process and it starts clockwise message sending.

Procedure is finished when a leader is choosen. Each process reports about its current state - keeping variables, passive/active state, information about leader.

Execution is stopped when all processes is informed about leader ID.

###Usage

Let's consider an example with 5 nodes (program allows implement algorithm with any amount of nodes).
We should run 5 instances [node.pl] (https://github.com/platomik/mie-dsv/blob/master/node.pl "node.pl").

	>./node.pl 
	ID : 59969
	connect to: 

Each process received uniqual identificator. Figure represents current phase of election procedure.

![](https://raw.github.com/platomik/mie-dsv/master/p1.jpg)

As we can see all processes are standalone and not connected. Next step is ring topology building. For each instance a predecessor must be choosen:

	>./node.pl 
	ID : 59969
	connect to: 37430

Figure shows current stage of election procedure. Nodes are connected and topology is built.

![](https://raw.github.com/platomik/mie-dsv/master/p2.jpg)

To initializate process of elections let's ping node with id 37430.

	>./ping.pl 37430
	
![](https://raw.github.com/platomik/mie-dsv/master/p3.jpg)


Message passing is started. Nodes in clockwise direction is exchanging information about their ID. After first round message transfering processes keep `d` and `e` variables, see figure:

![](https://raw.github.com/platomik/mie-dsv/master/p4.jpg)

Second message passing round finishes first step of election and starts stage of process state checking. 

![](https://raw.github.com/platomik/mie-dsv/master/p5.jpg)

At the stage of process state checking some nodes will become PASSIVE and start operate in transparent mode.

![](https://raw.github.com/platomik/mie-dsv/master/p6.jpg)

We lost 3 nodes from 5. Since now they operate in transparent node. We can check their output. For the process with id 59969 is looks like:
	
	>./node.pl 
	ID : 59969
	connect to: 37430
		Step: 1/1 [59969,40071,0]
		Step: 2/2 [59969,40071,44954]
	Become PASSIVE
		Step: 3/3 [59969,40071,44954]

Let's continue and perform two rounds of message passing between two remaining nodes.

![](https://raw.github.com/platomik/mie-dsv/master/p7.jpg)

Than after stage checking round only one node left. 

![](https://raw.github.com/platomik/mie-dsv/master/p8.jpg)

The output for the node 37430:

	>./node.pl 
	ID : 37430
	connect to: 33283
	Start election procedure
		Step: 1/1 [37430,59969,0]
		Step: 2/2 [37430,59969,40071]
		Step: 3/3 [59969,59969,40071]
		Step: 1/4 [59969,44954,40071]
		Step: 2/5 [59969,44954,59969]
	Become PASSIVE
		Step: 3/6 [59969,44954,59969]

We may notice that this node started election procedure. It mentioned in output. Node was active in 5 rounds.

Remaining only one node starts transfer information through passive nodes and get information about leader ID:

![](https://raw.github.com/platomik/mie-dsv/master/p9.jpg)

Output of the node 40071 is:

	>./node.pl 
	ID : 40071
	connect to: 59969
		Step: 1/1 [40071,44954,0]
		Step: 2/2 [40071,44954,33283]
		Step: 3/3 [44954,44954,33283]
		Step: 1/4 [44954,59969,33283]
		Step: 2/5 [44954,59969,44954]
		Step: 3/6 [59969,59969,44954]
		Step: 1/7 [59969,59969,44954]
		Step: 2/8 [59969,59969,59969]
	I know a leader! It is 59969
		Step: 3/9 [59969,59969,59969]
	Leader was found. It is 59969. Election procedure is finished.

Notice! The process itself does not have to become the new leader. The last round of elections is informing all processes about leader ID. All processes receive message and move to standby mode.

Here is full output of the node 33283.
	>./node.pl 
	ID : 33283
	connect to: 44954
		Step: 1/1 [33283,37430,0]
		Step: 2/2 [33283,37430,59969]
	Become PASSIVE
		Step: 3/3 [33283,37430,59969]Leader was found. It is 59969. Election procedure is finished.

Election is finished. Leader is known.

###Conclusions

