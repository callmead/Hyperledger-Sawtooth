echo 'Preparing to start...'
cd ~/Downloads/Sawtooth #navigate where you sawtooth installation is.
export SAWTOOTH_HOME=`pwd` #set home to the navigated dir.

echo "Would you like to start the components now? (y/n):"
read answer
if [ "$answer" != "${answer#[Yy]}" ] ;then
    echo 'Preparing to start...'
    #get ip address
    IP=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | head -n 1)
    echo 'IP Address of current node is:'$IP
    echo 'Would you like to keep the peering static instead of dynamic? (y/n):'
    read p_answer
    if [ "$p_answer" != "${p_answer#[Yy]}" ] ;then
        echo 'Static peering selected. Provide peer IPs in the following format'
        echo 'tcp://10.0.0.20:1003, tcp://10.0.0.21:1003, ...'
        read peer_ips
        #validator
        start_validator="sawtooth-validator -vv --bind component:tcp://127.0.0.1:4004 --bind network:tcp://$IP:8800 --endpoint tcp://$IP:8800 --bind consensus:tcp://127.0.0.1:5050 --peers $peer_ips"
        echo 'Validator: '$start_validator
        echo ''
    else
        echo 'Dynamic peering selected.'
        echo 'Please provide seed IP:'
        read seed_ip
        #validator
        start_validator="sawtooth-validator -vv --bind component:tcp://127.0.0.1:4004 --bind network:tcp://$IP:8800 --endpoint tcp://$IP:8800 --bind consensus:tcp://127.0.0.1:5050  --peering dynamic --seeds tcp://$seed_ip:8800"
        echo 'Validator: '$start_validator
        echo ''
    fi
    # RestAPI
    start_rest_api="sawtooth-rest-api -v --connect 127.0.0.1:4004" # not binding to any interface because no SW-CLI for now
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
    
    #-----------------------------------------------------------------------
    # Start all components in one terminal
    #-----------------------------------------------------------------------
    gnome-terminal --tab --command="bash -c '$start_validator; $SHELL'" \
                   --tab --command="bash -c '$start_rest_api; $SHELL'" \
                   --tab --command="bash -c '$start_settings_tp; $SHELL'" \
                   --tab --command="bash -c '$start_intkey_tp; $SHELL'" \
                   --tab --command="bash -c '$start_poet_tp; $SHELL'" \
                   --tab --command="bash -c '$start_poet_engine; $SHELL'"
    echo '*************************************************************************'
else
    echo 'Skipping start components...'
fi