TAPESTRY ALGORITHM - COP5615: Fall 2019

TEAM INFO
--------------------------------------------------------------------------------------------------------
Chandan Chowdary Kandipati (UFID 6972-9002)
Gayathri Manogna Isireddy (UFID 9124-0699)

PROBLEM STATEMENT
--------------------------------------------------------------------------------------------------------
Design Tapestry Algorithm using genserver/Actor model in Elixir to implement the network join and routing.

INSTALLATION AND RUN
---------------------------------------------------------------------------------------------------------
Elixir Mix project needs to be installed. The project lib folder contains the following files.

pilot.ex -> Main entry for the project, takes arguments from the command line.

actor.ex -> Contains code for actor nodes 

proj3.ex -> An empty project folder created during the creation of the project using Mix. 

To run a test case, do:

->Unzip contents to your desired elixir project folder.
->The executable file is already created under the name of peerex.
->To execute the file use the following command "./peerex <<number.of.nodes>> <<number.of.requests>>
->Optional => [If we want to compile the project and generate the executable file the following command needs to be executed in the path of project folder "mix run lib/pilot.ex".]
The result provides the maximum number of hops among all the hops that the nodes took to send message to their destination nodes.
Example:

chandan@chandan-HP-ENVY-x360-Convertible:~/Documents/proj3$ ./peerex 5000 10

Creating routing tables.........................
actors created with their routing tables!
Dynamic addition of additional nodes started............
Dynamic addition of additional nodes is done!
1 requests served
2 requests served
.
.
.
.
50009 requests served
50010 requests served

Maximum hop value is 3


WHAT IS WORKING
--------------------------------------------------------------------------------------------------------------
Tapestry algorithm is successfully implemented. To implement this algorithm we have created some nodes in the network. The count of nodes is given through command line as an argument. For each node a hash id is generated and is used as a unique identifier to identify a node in the network. Each node needs to send some requests to the nodes that are picked randomly in the network. This number of requests is also given as an argument through command line. Each node selects random nodes in the network and starts sending the requests to them. The maximum number of hops is that a request took to reach its destination is stored in the state of the initial node. These hops are collected in the end of the algorithm and maximum of them is returned.
Initially the routing tables of each node is calculated in a static way. After this a few nodes are joined dynamically in the way that is described in the research paper that is provided. The main funcitons that are implemented in the project include finding the next hop, finding the root node, sending message to the next hop and dynamic node creation.

LARGEST NETWORK
--------------------------------------------------------------------------------------------------------------
Largest network tested:

Largest Number of Nodes tested: 7000

Largest Number of Requests: 100

Result sample:

chandan@chandan-HP-ENVY-x360-Convertible:~/Documents/proj3$ ./peerex 7000 100

Creating routing tables.........................
actors created with their routing tables!
Dynamic addition of additional nodes started............
Dynamic addition of additional nodes is done!
1 requests served
2 requests served
.
.
.
.
700099 requests served
700100 requests served

Maximum hop value is 4

The largest problem that can be solved could be 10000 nodes as well. As we have limited computational resources we are able to achieve it till 7000 nodes. But it can be tested for any number of nodes that is larger than this on a system that could handle larger computations and storage.
