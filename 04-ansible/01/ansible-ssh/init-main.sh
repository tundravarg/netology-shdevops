#!/bin/bash


function main() {
    MSG=${MSG:-'.'}
    i=1

    while [ 1 ];
    do
        echo "$MSG-$i"
        i=$(( i + 1 ))
        sleep 10
    done
}
