#!/bin/bash

# Starts vcsim with the settings necessary for this sample
echo "Starting VCSIM in the background"
# See TODO below for why we're not starting blank today
# nohup vcsim -dc 0 -password pass -username user &
nohup vcsim -api-version 7.0u3 -standalone-host 3 -vm 0 -password pass -username user &
sleep 2
GOVCOUT=`head -n 1 nohup.out`
echo "  VCSIM output: $GOVCOUT"
# The following exports GOVC_URL
$GOVCOUT
# Allow self signed certs in all calls from the GOVC command line
export GOVC_INSECURE=true
# export

# TODO Fix the govmomi API layer (MoveTask) so the below can be 
#      done instead in Terraform itself as unadopted hosts

# echo "Creating base vSphere layer with 3 unadopted hosts"
# govc datacenter.create lab01.my.cloud
# govc host.add -hostname vesxi01.lab01.my.cloud -username root -password pass -noverify
# govc host.add -hostname vesxi02.lab01.my.cloud -username root -password pass -noverify
# govc host.add -hostname vesxi03.lab01.my.cloud -username root -password pass -noverify

echo "Ready for your Terraform commands"
read -p "Press Enter to quit vcsim"
kill $GOVC_SIM_PID