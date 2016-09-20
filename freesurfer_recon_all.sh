#!/bin/bash

#Freesurfer run
source freesurfer_variables.cfg
sublist=$(<subjects.txt)

for sub in $sublist; do
	recon-all -i $T1_location/$sub/$T1_name -subjid "sub_${sub}"
	recon-all -all -subjid "sub_${sub}"
	echo "${sub} completed" >> $log_freesurfer_recon_all/freesurfer_completed.txt
done

