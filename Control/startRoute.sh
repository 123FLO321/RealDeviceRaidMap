#!/bin/bash

while true
do
    while IFS=, read -r lat lon delay
    do
        idevicelocation -u $1 $lat $lon
        sleep $delay
    done < $2
done

