#!/bin/bash

source ~/open.rc

nova flavor-create --is-public True m1.small 3 512 10 1
nova flavor-create --is-public True m1.medium 5 1024 10 2
nova flavor-create --is-public True m1.medium 7 4096 10 4

