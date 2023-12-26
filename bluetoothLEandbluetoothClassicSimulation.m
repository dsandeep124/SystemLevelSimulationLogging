%   Copyright 2023 The MathWorks, Inc.

% Check if the 'Communications Toolbox (TM) Wireless Network Simulation
% Library' support package is installed. If the support package is not
% installed, MATLAB(R) returns an error with a link to download and
% install the support package.
wirelessnetworkSupportPackageCheck;

networkSimulator = wirelessNetworkSimulator.init();

% Create two Bluetooth BR/EDR nodes, specifying the role as "central"
% and "peripheral", respectively
centralNode = bluetoothNode("central", 'Name', 'central');
peripheralNode1 = bluetoothNode("peripheral", 'Name', 'peripheral-1', Position = [1 0 0]);
peripheralNode2 = bluetoothNode("peripheral", 'Name', 'peripheral-2', Position = [1 0 0]);

% Create a Bluetooth BR/EDR configuration object and share the
% connection between the Central and Peripheral nodes
cfgConnection = bluetoothConnectionConfig;
configureConnection(cfgConnection,centralNode,peripheralNode1);
configureConnection(cfgConnection,centralNode,peripheralNode2);

% Add application traffic from the Central to the Peripheral node
traffic = networkTrafficOnOff(DataRate=200,PacketSize=27, ...
    GeneratePacket=true,OnTime=inf);
addTrafficSource(centralNode,traffic,DestinationNode=peripheralNode1);
traffic = networkTrafficOnOff(DataRate=200,PacketSize=27, ...
    GeneratePacket=true,OnTime=inf);
addTrafficSource(peripheralNode1,traffic,DestinationNode=centralNode);

traffic = networkTrafficOnOff(DataRate=200,PacketSize=27, ...
    GeneratePacket=true,OnTime=inf);
addTrafficSource(centralNode,traffic,DestinationNode=peripheralNode2);
traffic = networkTrafficOnOff(DataRate=200,PacketSize=27, ...
    GeneratePacket=true,OnTime=inf);
addTrafficSource(peripheralNode2,traffic,DestinationNode=centralNode);

% Add the nodes to the simulator
addNodes(networkSimulator,[centralNode peripheralNode1 peripheralNode2]);

% Create two Bluetooth BR/EDR nodes, specifying the role as "central"
% and "peripheral", respectively
centralNode = bluetoothLENode("central", 'Name', 'central');
peripheralNode1 = bluetoothLENode("peripheral", 'Name', 'peripheral-1', Position = [1 0 0]);
peripheralNode2 = bluetoothLENode("peripheral", 'Name', 'peripheral-2', Position = [1 0 0]);

% Create a Bluetooth BR/EDR configuration object and share the
% connection between the Central and Peripheral nodes
cfgConnection = bluetoothLEConnectionConfig(ConnectionInterval=80e-3, ActivePeriod=40e-3);
configureConnection(cfgConnection,centralNode,peripheralNode1);
cfgConnection.ConnectionOffset=40e-3;
configureConnection(cfgConnection,centralNode,peripheralNode2);

% Add application traffic from the Central to the Peripheral node
traffic = networkTrafficOnOff(DataRate=200,PacketSize=27, ...
    GeneratePacket=true,OnTime=inf);
addTrafficSource(centralNode,traffic,DestinationNode=peripheralNode1);
traffic = networkTrafficOnOff(DataRate=200,PacketSize=27, ...
    GeneratePacket=true,OnTime=inf);
addTrafficSource(peripheralNode1,traffic,DestinationNode=centralNode);

traffic = networkTrafficOnOff(DataRate=200,PacketSize=27, ...
    GeneratePacket=true,OnTime=inf);
addTrafficSource(centralNode,traffic,DestinationNode=peripheralNode2);
traffic = networkTrafficOnOff(DataRate=200,PacketSize=27, ...
    GeneratePacket=true,OnTime=inf);
addTrafficSource(peripheralNode2,traffic,DestinationNode=centralNode);

% Add the nodes to the simulator
nodes=[centralNode peripheralNode1 peripheralNode2];
addNodes(networkSimulator,nodes);

% Create and add logger
simulationTime=0.1;
newEventLogger=eventLogger(networkSimulator.Nodes, simulationTime, DisplayEventLogs=true);

% Set the simulation time in seconds and run the simulation
run(networkSimulator,simulationTime);

% Retrieve statistics corresponding to the Central and Peripheral nodes
centralStats = statistics(centralNode);
peripheralStats = statistics(peripheralNode1);
