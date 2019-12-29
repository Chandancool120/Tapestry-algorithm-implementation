TAPESTRY ALGORITHM(Bonus Part) - COP5615: Fall 2019

TEAM INFO
--------------------------------------------------------------------------------------------------------
Chandan Chowdary Kandipati (UFID 6972-9002)
Gayathri Manogna Isireddy (UFID 9124-0699)

PROBLEM STATEMENT
--------------------------------------------------------------------------------------------------------
Design Tapestry Algorithm using genserver/Actor model in Elixir to implement the network join and routing. This folder contains that bonus part that we have implemented as desired.

INSTALLATION AND RUN
---------------------------------------------------------------------------------------------------------
Elixir Mix project needs to be installed. The project lib folder contains the following files.

pilot_bonus.ex -> Main entry for the project, takes arguments from the command line along with the number of failure nodes.

actor.ex -> Contains code for actor nodes 

proj3.ex -> An empty project folder created during the creation of the project using Mix. 

To run a test case, do:

->Unzip contents to your desired elixir project folder.
->The executable file is already created under the name of peerex.
->To execute the file use the following command "./peerex <<number.of.nodes>> <<number.of.failNodes>> <<number.of.requests>>
->Optional => [If we want to compile the project and generate the executable file the following command needs to be executed in the path of project folder "mix run lib/pilot_bonus.ex".]
The result provides the maximum number of hops among all the hops that the nodes took to send message to their destination nodes.
Example:

chandan@chandan-HP-ENVY-x360-Convertible:~/Documents/proj3_bonus$ ./peerex 10 2 1

Creating routing tables.........................
actors created with their routing tables!
Dynamic addition of additional nodes started............
Dynamic addition of additional nodes is done!
Process with #PID<0.102.0> killed
Process with #PID<0.101.0> killed
Processes killing is done.
1 requests served
2 requests served
3 requests served
4 requests served
5 requests served
6 requests served
7 requests served
8 requests served
9 requests served
Maximum hop value is 1


WHAT IS WORKING
--------------------------------------------------------------------------------------------------------------
Tapestry algorithm is successfully implemented along with the bonus part. To implement this algorithm we have created some nodes in the network. Routing tables of all the nodes in the network are created along with the dynamic nodes just like we calculated in part 1(non bonus part). To make the system fault tolerant, there is a slight modification in the approach. In the earlier approach, a single matching node in inserted at the suitable position in the routing table of each node. But in this case a list of nodes is inserted at each position in routing table. If a node that is killed is picked from this list as a next hop, then we are checking if the node is killed or alive. If the node is alive we pick up the node and proceed with the algorithm, else the node will be dropped and another node will be picked up from the list. In this way whenever a killed node is picked as next hop, that node is dropped and another node which matches with the destination node from the same list is picked up and sent as a next hop. If a destination node is killed, then the hops that are calculated till the level before it reached destination is stored and is returned.

LARGEST NETWORK
--------------------------------------------------------------------------------------------------------------
Largest network tested:

Largest Number of Nodes tested: 7000

Largest Number of Requests: 10

Result sample:

chandan@chandan-HP-ENVY-x360-Convertible:~/Documents/proj3_bonus$ ./peerex 7000 30 10

Creating routing tables.........................
actors created with their routing tables!
Dynamic addition of additional nodes started............
Dynamic addition of additional nodes is done!
Process with #PID<0.102.0> killed
Process with #PID<0.101.0> killed
.
.
.
Process with #PID<0.111.0> killed
1 requests served
2 requests served
.
.
.
.
69709 requests served
69710 requests served

Maximum hop value is 4


The largest problem that can be solved could be 10000 nodes as well. As we have limited computational resources we are able to achieve it till 7000 nodes. But it can be tested for any number of nodes that is larger than this on a system that could handle larger computations and storage.
