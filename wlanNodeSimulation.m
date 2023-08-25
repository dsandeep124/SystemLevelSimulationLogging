%   Copyright 2023 The MathWorks, Inc.

% Check if the 'Communications Toolbox (TM) Wireless Network Simulation
% Library' support package is installed. If the support package is not
% installed, MATLAB(R) returns an error with a link to download and
% install the support package.
wirelessnetworkSupportPackageCheck;

% Initialize wireless network simulator
networksimulator = wirelessNetworkSimulator.init(EnableEventsLogger=true, DisplayEventLogs=true);

% Create a WLAN node with AP device configuration
apDeviceCfg = wlanDeviceConfig(Mode="AP");
apNode = wlanNode(Name="AP",DeviceConfig=apDeviceCfg);

% Create a WLAN node with STA device configuration
staDeviceCfg = wlanDeviceConfig(Mode="STA");
staNode = wlanNode(Name="STA",DeviceConfig=staDeviceCfg);

% Associate the STA to the AP and configure downlink full buffer traffic
associateStations(apNode,staNode,FullBufferTraffic="DL");

% Add nodes to the simulation
addNodes(networksimulator,[apNode,staNode]);

% Run simulation for 1 second
run(networksimulator,1);

% Retrieve and display statistics of AP and STA
apStats = statistics(apNode);
staStats = statistics(staNode);