#!/bin/bash
        MYJWT=`cat test.jwt`
        CLOUDLB=`cat cloudlb.txt`
        A=0
        while [ $A -lt 10 ]; do
                curl $CLOUDLB/v1/jwt -H "Authorization: Bearer $MYJWT"
                curl $CLOUDLB/v1/jwt -H "Authorization: Bearer $MYJWT"
#                sleep .2
                curl $CLOUDLB/v1/jwt -H "Authorization: Bearer $MYJWT"
                curl $CLOUDLB/v1/jwt -H "Authorization: Bearer $MYJWT"
#                sleep .2
                curl $CLOUDLB/v1/jwt -H "Authorization: Bearer $MYJWT"
                curl $CLOUDLB/v1/jwt -H "Authorization: Bearer $MYJWT"
                let A=A+1
        done
