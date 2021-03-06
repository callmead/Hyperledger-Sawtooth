# Script v2
# Run script: 	./poet_mode2 param1 param2 param3 param4
# Example: 	./poet_mode2.sh deploy_genesis(y/n) start_components(y/n) static_peering(y/n) peers(tcp://ip:port,tcp://ip:port,...)
echo '*************************************************************************'
echo 'Installing Sawtooth v1.1.4-1 in PoET mode...'
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 8AA7AF1F1091A5FD 
add-apt-repository 'deb [arch=amd64] http://repo.sawtooth.me/ubuntu/bumper/stable xenial universe'
apt-get update # update repo
apt-get -y install sawtooth # install sawtooth
apt-get install -y python3-sawtooth-poet-engine # install poet engine
apt-get install sawtooth-devmode-engine-rust

#create folders
mkdir Sawtooth
cd Sawtooth
mkdir data
mkdir logs
mkdir keys
mkdir results
mkdir policy
chmod 777 results 
export SAWTOOTH_HOME=`pwd`

#Generate User Key: 
sawtooth keygen

#Generate the key for the validator 
sawadm keygen 

#Ensure user/validator keys exist: 
ls ~/.sawtooth/keys/ 
ls /etc/sawtooth/keys/ 
echo '*************************************************************************'
dpkg -l '*sawtooth*'
echo ''
echo '*************************************************************************'
if [ "$1" != "${1#[Yy]}" ] ;then #$1 first paramemter y/n to install genesis
    echo 'Preparing to install genesis...' 
    #Create a batch to initialize the Settings transaction family in the genesis block: 
    sawset genesis -k keys/validator.priv -o config-genesis.batch
	
    #Create a batch to initialize the PoET consensus settings: 
    sawset proposal create -k keys/validator.priv -o config.batch \
    sawtooth.consensus.algorithm.name=PoET \
    sawtooth.poet.report_public_key_pem="$(cat /etc/sawtooth/simulator_rk_pub.pem)" \
    sawtooth.poet.valid_enclave_measurements=$(poet enclave measurement) \
    sawtooth.poet.valid_enclave_basenames=$(poet enclave basename)
    
    #Create a batch to register the first validator with the Validator Registry:	
    poet registration create -k keys/validator.priv -o poet.batch
	
    #(Optional) Create a batch to configure optional PoET settings.
    sawset proposal create -k keys/validator.priv -o poet-settings.batch \
    sawtooth.poet.target_wait_time=5 \
    sawtooth.poet.initial_wait_time=25 \
    sawtooth.publisher.max_batches_per_block=100
	
    #Combine the previously created batches into a single genesis batch that will be committed in the genesis block. 
    sawadm genesis config-genesis.batch config.batch poet.batch poet-settings.batch 
    echo '*************************************************************************'
    else
        echo 'Skipping creation of genesis block...'
fi

if [ "$2" != "${2#[Yy]}" ] ;then #$2 second paramemter y/n to start components
    echo 'Starting components...'
    #get ip address
    IP=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | head -n 1)
    echo 'IP Address of current node is:'$IP

    if [ "$3" != "${3#[Yy]}" ] ;then #$3 peering static y/n and $4 peer IP addresses
        echo 'Static peering selected.'
        #validator
        start_validator="sawtooth-validator -vv --bind component:tcp://127.0.0.1:4004 --bind network:tcp://$IP:8800 --endpoint tcp://$IP:8800 --bind consensus:tcp://127.0.0.1:5050 --peers $4"
        echo 'Validator: '$start_validator
        echo ''
    else
        echo 'Dynamic peering selected.'		
        #validator
        start_validator="sawtooth-validator -vv --bind component:tcp://127.0.0.1:4004 --bind network:tcp://$IP:8800 --endpoint tcp://$IP:8800 --bind consensus:tcp://127.0.0.1:5050  --peering dynamic --seeds $4"
        echo 'Validator: '$start_validator
        echo ''
    fi
    # RestAPI
    start_rest_api="sawtooth-rest-api -v --connect tcp://127.0.0.1:4004" # not binding to any interface because no SW-CLI for now
    echo 'REST-API: '$start_rest_api
    echo ' '
    #processors
    start_settings_tp="settings-tp -v --connect tcp://127.0.0.1:4004"
    echo 'settings: '$start_settings_tp
    echo ' '
    start_intkey_tp="intkey-tp-python -v --connect tcp://127.0.0.1:4004"
    echo 'intkey-tp-python: '$start_intkey_tp    
    echo ' '    
    start_poet_tp="poet-validator-registry-tp --connect tcp://127.0.0.1:4004"
    echo 'PoET TP: '$start_poet_tp
    echo ' '
    start_poet_engine="poet-engine -v --connect tcp://127.0.0.1:5050 --component tcp://127.0.0.1:4004"
    echo 'PoET Engine: '$start_poet_engine
    
    # Start all components under one terminal multiple tabs...
    gnome-terminal --tab --command="bash -c '$start_validator; $SHELL'" \
                   --tab --command="bash -c '$start_rest_api; $SHELL'" \
                   --tab --command="bash -c '$start_settings_tp; $SHELL'" \
                   --tab --command="bash -c '$start_intkey_tp; $SHELL'" \
                   --tab --command="bash -c '$start_poet_tp; $SHELL'" \
                   --tab --command="bash -c '$start_poet_engine; $SHELL'"
    echo '*************************************************************************'
else
    echo 'Skipping Start components...'
fi
