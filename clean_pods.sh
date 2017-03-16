#!/bin/bash

echo "Launching class PODs 1-8"

for ((n=1;n<9;n++))
do
  echo 'yes' | terraform destroy \
    -backup=- -state=./pod$n.tfs ubuntu-packet.tf
done
