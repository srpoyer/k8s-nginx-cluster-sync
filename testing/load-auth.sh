#!/bin/bash
        A=0
        CLOUDLB=`cat cloudlb.txt`
        while [ $A -lt 10 ]; do
                curl $CLOUDLB/v1/auth -H "auth:abc"
                curl $CLOUDLB/v1/auth -H "auth:abc"
#                sleep .2
                curl $CLOUDLB/v1/auth -H "auth:abc"
                curl $CLOUDLB/v1/auth -H "auth:abc"
#                sleep .2
                curl $CLOUDLB/v1/auth -H "auth:abc"
                curl $CLOUDLB/v1/auth -H "auth:abc"
                let A=A+1
        done
