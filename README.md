# SystemLevelSimulationLogging
Utilize the Events mechanism available in System Level Simulation (SLS) capabilities in **Mathworks Bluetooth(R) Toolbox, WLAN Toolbox and 
Communications Toolbox Wireless Network Simulation Library Support Package**

In addition to normal system level simulations performed using Bluetooth Toolbox or WLAN Toolbox using the node features, this setup will help to log the internal events happening during the simulations and be able to view them at the end of the simulation.

Some snippets using the sample scripts attached in the repo.
# Bluetooth LE SLS Events Log using sample script:
![Bluetooth LE SLS Events Log](EventsLog_1.png?raw=true "Bluetooth LE SLS Events Log")

# Bluetooth LE+Classic Bluetooth SLS Events Log using sample script:
![Bluetooth LE & Bluetooth Classic SLS Events Log](EventsLog_2.png?raw=true "Bluetooth LE & Bluetooth Classic SLS Events Log")

# WLAN SLS Events Log using sample script:
![SLS Events Log](EventsLog_3.png?raw=true "SLS Events Log")

In order to simplify things, the main feature used for this SLS, 
**wirelessNetworkSimulator (from R2023b) has been updated a little bit for flexibility and shared here as a p-coded file which I guess will be under "MathWorks Limited License"**
**Rest of the files in the repo are under "BSD License" as part of Mathworks File Exchange guidelines.**
