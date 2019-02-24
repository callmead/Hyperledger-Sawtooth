# Installation Guide

These scripts will install Sawtooth 1.1.4 network with the PoET consensus mode. 
Detailed instructions can be found on the the [Creating Sawtooth Network](https://sawtooth.hyperledger.org/docs/core/nightly/master/app_developers_guide/creating_sawtooth_network.html?highlight=selecting%20consensus) page

### Prerequisites

Ubuntu 16.04 LTS nodes. At least 3 nodes. 

## Script descriptions

* poet_mode.sh - Installs the required packages, genesis block and starts the components. 
* start_components_poet.sh - Starts the components

### Steps to follow

Once you have Ubuntu nodes ready and scripts downloaded on the nodes, copy the scripts under the Downloads folder. Open terminal in the Downloads folder and run the following commands. The first command makes the scripts executable and the second command executes the main installation script. 

```
sudo chmod u+x *.sh
sudo ./poet_mode.sh
```

Please note, during installation, the script will guide and ask your input. 
The first question you will be asked is

```
Ensure keys and packags above before continue. Would you like to create the Genesis block now? (y/n)?
```
You need to ensure if all the packages are installed and most importantly, the keys are generated. 
On the first node, you will press 'y' to create the genesis block but on the following nodes, you will press 'n'

The second question you will be asked is

```
Would you like to start the components now? (y/n)
```
If you want to start components immediately, you can press 'y' and start the components on the current node.
You can start the components later also by running the second script "start_components.sh"
During the component run, you will be asked the following questions

```
Would you like to keep the peering static instead of dynamic? (y/n):
```
The idea of this question is to give the user flexibility of selecting Static or Dynamic peering at will while starting the components.

## Built With

* If peering is dynamic, you can enter a partial list of URLs. Sawtooth will automatically discover the other nodes on the network.
* If peering is static, you must list the URLs of all peers that this node should connect to.

if you select y in the above question, keeping peering static, you must provide the peers like
```
tcp://10.0.0.20:8800,tcp://10.0.0.21:8800,...
```
The IP addresses of the peer nodes with the default port numbers 8800 or if you are using any other port, you can use that.

If you have selected dynamic peering, you will be asked for seed IP.
```
Please provide seed IP:
```
You can provide the first node IP.

Based on your selected peering mode, validator will start followed by Rest API, Transaction processors and the PoET engine. 

## Missing pieces on the Sawtooth documentation

* Starting the validator is missing the consensus bind "--bind consensus:tcp://127.0.0.1:5050"
* Starting the PoET engine statement is missing "poet-engine -v --connect tcp://127.0.0.1:5050 --component tcp://127.0.0.1:4004"
