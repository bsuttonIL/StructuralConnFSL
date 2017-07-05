#!/bin/bash

#Created by Paul Sharp and Brad Sutton 12-21-2016

# This batch file pushes the connectivity and bedpostx results to AWS or a network drive

# MOVE RESULTS BACK TO ORIGINAL STUDY FOLDER AND CLEAN UP
# MOVE connectome_camino_hagmannorder_weighted.csv

if [ $NETWORK_DRIVE = "1" ];
then
   mkdir -p ${STUDY_CONDIR}
   cp ${RESDIR}/*.csv ${STUDY_CONDIR}
   mkdir -p ${STUDY_BEDPOSTDIR}
  cp -r ${DATBEDPOSTDIR} ${STUDY_BEDPOSTDIR}
else
  aws s3 sync ${RESDIR} s3:/${STUDY_CONDIR}
  aws s3 sync ${DATBEDPOSTDIR} s3:/${STUDY_BEDPOSTDIR}

  #terminate command here???
fi
