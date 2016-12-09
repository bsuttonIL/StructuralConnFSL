#!/bin/bash

#Created by Paul Sharp and Brad Sutton 10-7-2016

# This batch file runs creates structural connectomes for any parcellation on 
# raw DTI data. 

# MUST READ BELOW TO MAKE SURE SCRIPT RUNS:
# Need a SCRIPTS_DIR with all approriate scripts 
# Make sure FreeSurfer recon-all is run first 
  

# !!!!!!!! NOTE: SUBJECTS_DIR must be the temp SUBJECTS DIR, NOT THE ONE ON THE SERVER!
#  SUBJECTS_DIR must be the /usr/local/freesurfer   !!!!!
# !!!!!!!!   THERE IS A RM -RF SUBJECT_DIR

source connectome_variables.cfg

sublist=$(<subjects.txt)

mkdir ${DATA_DIR}

export SCRIPTS_DIR

sudo chmod ugo+rwx ${SUBJECTS_DIR}

for sub in ${sublist} 
do 

  export sub
  #ORIGINAL DATA LOCATION
  #location of DTI files
  STUDY_DATDIR=${STUDY_DATA_DIR}/${sub}/${STUDY_DTIPTH}/
  #location of bedpost directory
  STUDY_BEDPOSTDIR=${STUDY_DATA_DIR}/${sub}/${DTIPTH}.bedpostX/
  #location of freesurfer subject data
  STUDY_FSDIR=${STUDY_SUBJECTS_DIR}/${sub}/
  #location of connectome output
  STUDY_CONDIR=${STUDY_DATA_DIR}/${sub}/${STUDY_CONN_PATH}
  
  #local TEMPORARY data locations for processing
  FSDIR=${SUBJECTS_DIR}/${sub}
  DATDIR=${DATA_DIR}/${sub}/DTI/analyses/
  RESDIR=${DATA_DIR}/${sub}/ConnFSL
  DATBEDPOSTDIR=${DATA_DIR}/${sub}/DTI/analyses.bedpostX/
    
  # MOVE DATA OVER TO TEMP DIRECTORIES
  mkdir ${DATA_DIR}/${sub}/
  mkdir ${DATA_DIR}/${sub}/DTI/
  mkdir ${DATDIR}
  # mkdir ${DATBEDPOSTDIR}  # We are running bedpost ourselves

  cp -r ${STUDY_DATDIR}* ${DATDIR}
  mkdir ${FSDIR}
  cp -r ${STUDY_FSDIR}* ${FSDIR}
  
  export DATDIR
  export RESDIR

  #local results directory
  mkdir ${RESDIR}
  cd ${RESDIR}
  
  # PROCESS DTI - make sure nodif brain mask is right size, etc. 
  cd ${DATDIR}
  fslroi ${DTI_raw} nodif 0 1
	bet nodif nodif_brain -f 0.1 -m
	eddy_correct ${DTI_raw} data 0
	fdt_rotate_bvecs ${Bvec_naming} bvecs data_ecc.ecclog
		
  cd ${RESDIR}
       
  
  # Create registration matrix from DTI -> FS:
  bbregister --s ${sub} --mov ${DATDIR}/nodif_brain.nii.gz --reg ${RESDIR}/diff_2_fs.data --dti --init-fsl


  # Invert matrix to take FS to DTI Space:
  mri_vol2vol --mov ${DATDIR}/nodif_brain.nii.gz --targ ${SUBJECTS_DIR}/${sub}/mri/${parcellation_image} --o ${RESDIR}/FS_to_DTI.nii.gz --reg ${RESDIR}/diff_2_fs.data --inv --nearest
  

  cd ${RESDIR}  # should still be in there, but just to make sure


  echo "Running Bedpost"
  bedpostx ${DATDIR}
  

  # create CSF mask
  chmod +x ${SCRIPTS_DIR}/CSF_mask.sh
  ${SCRIPTS_DIR}/CSF_mask.sh

  #Generate ROIs for tractography AND get volumes of each ROI for later weighting in a CSV file
  python ${SCRIPTS_DIR}/Freesurfer_ROIs.py

  cd ${DATBEDPOSTDIR}
  #Run probtrackx 
  echo "Running Probtrackx2"
  probtrackx2 --network -x ${RESDIR}/masks.txt -l -c 0.2 -S 2000 --steplength=0.5 -P 5000 --fibthresh=0.01 --distthresh=0.0 --avoid=${RESDIR}/CSFmask.nii.gz --sampvox=0.0 --forcedir --opd -s ${DATBEDPOSTDIR}/merged -m ${DATBEDPOSTDIR}/nodif_brain_mask --dir=${RESDIR} 

  cd ${RESDIR}

  #convert naming of raw connectome file
  python ${SCRIPTS_DIR}/FSL_convert_fdtmatrix_csv.py
  #compute transformation on Connectivity matrix 
  python ${SCRIPTS_DIR}/volume_weight_connectome.py 
  #add column headers for connectome file which is required for visualization
  python ${SCRIPTS_DIR}/add_column_headers.py
  
  # MOVE RESULTS BACK TO ORIGINAL STUDY FOLDER AND CLEAN UP
  # MOVE connectome_camino_hagmannorder_weighted.csv

  mkdir ${STUDY_DATA_DIR}/${sub}/Analyze/Connectome/
  mkdir ${STUDY_CONDIR}
  cp ${RESDIR}/*.csv ${STUDY_CONDIR}
  mkdir ${STUDY_BEDPOSTDIR}
  cp -r ${DATBEDPOSTDIR} ${STUDY_BEDPOSTDIR}
  
  #rm -Rf ${FSDIR}   # THIS CAN BE USED TO CLEAN UP THE LOCAL FREESURFER DIRECTORY
  #rm -Rf ${DATDIR}
  #rm -Rf ${RESDIR}
  #rm -Rf ${DATBEDPOSTDIR}
 

done



