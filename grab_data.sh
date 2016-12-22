#!/bin/bash

#Created by Paul Sharp and Brad Sutton 12-21-2016

# This batch file grabs the DTI and freesurfer data from AWS or a network drive



if [ $NETWORK_DRIVE = "1" ];
then
  cp -r ${STUDY_DATDIR}* ${DATDIR}
  mkdir ${FSDIR}
  cp -r ${STUDY_FSDIR}* ${FSDIR}
else
  aws configure set region us-west-2
  aws s3 sync s3:/${STUDY_DATDIR} ${DATDIR}
  mkdir ${FSDIR}
  aws s3 sync s3:/${STUDY_FSDIR} ${FSDIR}
fi
