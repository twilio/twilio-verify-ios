#!/bin/bash

cd ..
twilioVerifyConfig=`cat TwilioVerifySDK/TwilioVerify/Sources/TwilioVerifyConfig.swift`
SAVEIFS=$IFS
IFS=$'\n'
components=($twilioVerifyConfig)
IFS=$SAVEIFS

for (( i=0; i<${#components[@]}; i++ ))
do
  if [[ ${components[$i]} == "let version ="* ]]; then
    version=$(echo ${components[$i]} | cut -d"\"" -f2)
 fi
done

jazzy \
  --output docs/$version/ \
  --theme apple

cd docs
ln -nsf "$version" latest 
