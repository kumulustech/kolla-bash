#!/bin/bash
set -x
echo "Launching class PODs 1-8"

for ((n=1;n<9;n++))
do
  terraform apply\
    -backup=- -state=./pod$n.tfs \
    -var control_name=control$n -var compute_name=compute$n \
#    -var domain_name=opsits.com
done
