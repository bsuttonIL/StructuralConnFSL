#!/bin/bash

#start with the freesurfer already run
#freesurfer is in SUBJECTS_DIR/subid
#DWI data is in DATA_DIR/subid/DTI/ along with bval and bvecs

# RUN THIS FIRST IN FREESURFER SUBJECTS DIRECTORY
  # To convert to Hagmann labels. Need get_subjects.py in same path
  # THIS IS RUN ON ALL FREESURFER, SO JUST PULL OUT AND RUN SEPARATELY
  #   python convert_fs_labels_to_hagmann.py

# !!!!!!!! NOTE: SUBJECTS_DIR must be the temp SUBJECTS DIR, NOT THE ONE ON THE SERVER!
#  SUBJECTS_DIR must be the /usr/local/freesurfer   !!!!!
# !!!!!!!!   THERE IS A RM -RF SUBJECT_DIR

source connectome_variables.cfg

# SUBJECTS_DIR=/usr/local/freesurfer/subjects

sublist=$(<subjects.txt)

# TMP DIRECTORY FOR PROCESSING
# DATA_DIR=/home/bsutton/Processing
mkdir ${DATA_DIR}

# SCRIPTS_DIR=/home/bsutton/Scripts/ProcessingPipelines/StructConn_FSL
# CONN_DIR=${SCRIPTS_DIR}
export CONN_DIR


#Directory that has DTI, INSIDE EACH DATA DIRECTORY
# data.nii.gz is in ${INSIGHT_DATA_DIR}/${sub}/${DTIPTH}/


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
  STUDY_CONDIR=${STUDY_DATA_DIR}/${sub}/Analyze/Connectome/FSL_68ROI/
  
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
  
  #PROCESS DTI - make sure nodif brain mask is right size, etc. 
  cd ${DATDIR}
  fslroi ${DTI_raw} nodif 0 1
	bet nodif nodif_brain -f 0.1 -m
	eddy_correct data data_ecc 0
	fdt_rotate_bvecs bvecs rot_bvecs dti_ecc.ecclog
	mv bvecs old_bvecs && mv rot_bvecs bvecs
		
	dtifit -k data_ecc -o dti -m nodif_brain_mask -r bvecs -b bvals
  cd ${RESDIR}
       
  
  
  
  
  #NOW TO FREESURFER
  
  #VOLUME OF REGIONS
  aparcstats2table --hemi rh --subjects ${sub} --meas volume --tablefile rh_volumes_stats.txt
  aparcstats2table --hemi lh --subjects ${sub} --meas volume --tablefile lh_volumes_stats.txt

  #Create registration matrix from DTI -> FS:
  bbregister --s ${sub} --mov ${DATDIR}/nodif_brain.nii.gz --reg ${RESDIR}/diff_2_fs.data --dti --init-fsl


  #Invert matrix to take FS to DTI Space:
  mri_vol2vol --mov ${DATDIR}/nodif_brain.nii.gz --targ ${SUBJECTS_DIR}/${sub}/mri/aparc+aseg.mgz --o ${RESDIR}/FS_to_DTI.nii.gz --reg ${RESDIR}/diff_2_fs.data --inv --nearest
  

  cd ${RESDIR}  # should still be in there, but just to make sure


  echo "Running Bedpost"
  bedpostx ${DATDIR}
  
  #create CSF mask
  chmod +x CSF_mask.sh
  ./CSF_mask.sh

  #converts to hagmann labels
  # python ${SCRIPTS_DIR}/convert_fs_labels_to_hagmann.py
  # #create masks text file for probtrackx2, OUTPUTS IN RESDIR
  # python ${SCRIPTS_DIR}/create_masks.py

  python ${SCRIPTS_DIR}/Freesurfer_ROIs.py

  cd ${DATBEDPOSTDIR}
  #Run probtrackx 
  echo "Running Probtrackx2"
  probtrackx2 --network -x ${RESDIR}/masks.txt -l -c 0.2 -S 2000 --steplength=0.5 -P 5000 --fibthresh=0.01 --distthresh=0.0 --avoid=CSFmask.nii.gz --sampvox=0.0 --forcedir --opd -s ${DATBEDPOSTDIR}/merged -m ${DATBEDPOSTDIR}/nodif_brain_mask --dir=${RESDIR} 

  cd ${RESDIR}

  python ${SCRIPTS_DIR}/FSL_convert_fdtmatrix_csv.py
  # #compute transformation on Connectivity matrix 
  python ${SCRIPTS_DIR}/FSL_weight_connectome_Hagmann_equation.py 
  # #add column headers for 
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



