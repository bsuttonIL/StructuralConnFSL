	
#  Script written by Paul SHarp 8-4-205
#  CHANGES 2-23-16
#
#  This script NEEDS two accompanying text files IN THE SAME PATH
#  as THIS SCRIPT: "fs_labels_hagamann_order.txt" and "aparc_labels.txt"
#  
#  This script does two things for each subject in your study
#
#
#  (1) Takes aparc_aseg.nii.gz output from Freesurfer's recon-all
#      and eliminates all subcortical structures (via FSL's fslmaths 
#	   threshold and subtract options) and eliminates cortical insula
#      to provide just a 68 region (34 per hemisphere) parcellated cortex
#	   to be used in a subsequent connectome construction algorithm
#       
#
#  (2) Assigns new intensity values to recon-all, 68-region parcellated
#      NIFTI image that in the same sequential order as the Hagmann-Sporns
#      strucutral parcellation


import nipype.interfaces.fsl as fsl
import os


Hagmann_Order = {}
cortical_ROIS=[]
with open('{}/fs_labels_hagmann_order.txt'.format(os.environ['CONN_DIR']), 'r') as f:
	for line in range(68):
		current_line = f.readline()
		if line == 67:
			current_line = current_line.split()
		else:
			current_line = current_line[:-1]
			current_line = current_line.split()
		Hagmann_Order[current_line[1]]=int(current_line[0])
		cortical_ROIS.append(current_line[1])


Freesurfer_Order = {}
with open('{}/aparc_labels.txt'.format(os.environ['CONN_DIR']), 'r') as f:
	for line in range(68):
		current_line = f.readline()
		if line == 67:
			current_line = current_line.split()
		else:
			current_line = current_line[:-1]
			current_line = current_line.split()
		Freesurfer_Order[current_line[1]]=int(current_line[0])




#os.chdir('{}/{}'.format(data_dir,subject))	

#eliminate all ROIS in aparc_aseg niftii image EXCEPT 68 cortical regions used for connectome construction
get_WM_ROI = fsl.maths.Threshold()
get_WM_ROI.inputs.in_file = 'FS_to_DTI.nii.gz'
get_WM_ROI.inputs.thresh = 1000.5
get_WM_ROI.inputs.out_file = 'FS_TO_DTI_cortical.nii.gz'
get_WM_ROI.run()

get_WM_ROI = fsl.maths.Threshold()
get_WM_ROI.inputs.in_file = 'FS_TO_DTI_cortical.nii.gz'
get_WM_ROI.inputs.thresh = 1035.5
get_WM_ROI.inputs.args = '-uthr {}'.format(2000.5)
get_WM_ROI.inputs.out_file = 'old_ROI.nii.gz'
get_WM_ROI.run()

subtract_former_ROI = fsl.maths.BinaryMaths()
subtract_former_ROI.inputs.in_file = 'FS_TO_DTI_cortical.nii.gz'
subtract_former_ROI.inputs.operation = 'sub'
subtract_former_ROI.inputs.operand_file = 'old_ROI.nii.gz'
subtract_former_ROI.inputs.out_file = 'FS_TO_DTI_cortical.nii.gz'
subtract_former_ROI.run()

get_upper_ROI = fsl.maths.Threshold()
get_upper_ROI.inputs.in_file = 'FS_TO_DTI_cortical.nii.gz'
get_upper_ROI.inputs.thresh = 2035.5
get_upper_ROI.inputs.out_file = 'old_ROI.nii.gz'
get_upper_ROI.run()

subtract_former_ROI = fsl.maths.BinaryMaths()
subtract_former_ROI.inputs.in_file = 'FS_TO_DTI_cortical.nii.gz'
subtract_former_ROI.inputs.operation = 'sub'
subtract_former_ROI.inputs.operand_file = 'old_ROI.nii.gz'
subtract_former_ROI.inputs.out_file = 'FS_TO_DTI_cortical.nii.gz'
subtract_former_ROI.run()


#Change ROIs from Freesurfer values to Hagmann-Sporns values

for index in range(68):           # index goes 1:68
	print 'Region Number {}'.format(index+1)
	x = Freesurfer_Order[cortical_ROIS[index]]     # x is in the 1000's , cannot overlap with 1:68 or problems will occur.
	get_WM_ROI = fsl.maths.Threshold()
	get_WM_ROI.inputs.in_file = 'FS_TO_DTI_cortical.nii.gz'
	get_WM_ROI.inputs.thresh = x-0.5
	get_WM_ROI.inputs.args = '-uthr {}'.format(x+0.5)
	get_WM_ROI.inputs.out_file = 'old_ROI.nii.gz'
	get_WM_ROI.run()

	subtract_former_ROI = fsl.maths.BinaryMaths()
	subtract_former_ROI.inputs.in_file = 'FS_TO_DTI_cortical.nii.gz'
	subtract_former_ROI.inputs.operation = 'sub'
	subtract_former_ROI.inputs.operand_file = 'old_ROI.nii.gz'
	subtract_former_ROI.inputs.out_file = 'FS_TO_DTI_cortical.nii.gz'
	subtract_former_ROI.run()

	binarize_ROI = fsl.maths.UnaryMaths()
	binarize_ROI.inputs.in_file = 'old_ROI.nii.gz'
	binarize_ROI.inputs.operation = 'bin'
	binarize_ROI.inputs.out_file = 'bin_ROI.nii.gz'
	binarize_ROI.run()

	change_ROI = fsl.maths.BinaryMaths()
	change_ROI.inputs.in_file = 'bin_ROI.nii.gz'
	change_ROI.inputs.operation = 'mul'
	change_ROI.inputs.operand_value = Hagmann_Order[cortical_ROIS[index]]
	change_ROI.inputs.out_file = 'ROI_{}.nii.gz'.format(index+1) 
	change_ROI.run()

	new_ROI = fsl.maths.BinaryMaths()
	new_ROI.inputs.in_file = 'FS_TO_DTI_cortical.nii.gz'
	new_ROI.inputs.operation = 'add'
	new_ROI.inputs.operand_file = 'ROI_{}.nii.gz'.format(index+1)
	new_ROI.inputs.out_file = 'FS_TO_DTI_cortical.nii.gz'
	new_ROI.run()

