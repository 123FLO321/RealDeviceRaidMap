#!/bin/bash

while true
do
    xcodebuild test -scheme "RDRaidMapCtrl" -destination "id=$1"
done
