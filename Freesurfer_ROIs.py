#Creates ROI masks fom Freesurfer parcellation (which has previous been transformed to DTI Space)

import os
import nipype.interfaces.fsl as fsl


Freesurfer_Regions_dict = {}
Freesurfer_Regions_list=[]

with open('{}/aparc_cort_subcort_labels.txt'.format(os.environ['CONN_DIR']), 'r') as f:
	for line in range(88):
		current_line = f.readline()
		if line == 87:
			current_line = current_line.split()
		else:
			current_line = current_line[:-1]
			current_line = current_line.split()
		Freesurfer_Regions_dict[current_line[1]]=int(current_line[0])
		Freesurfer_Regions_list.append(current_line[1])

#create text file with all ROI masks
with open('masks.txt', 'w') as f:
	for roi in Freesurfer_Regions_list:
		f.write('{}/{}.nii.gz\n'.format(os.environ['RESDIR'], roi))


#create each ROI niftii file
for index in range(88):           # index goes 1:68
	print 'Region Number {}'.format(index+1)
	x = Freesurfer[corROIS[index]]     # x is in the 1000's , cannot overlap with 1:68 or problems will occur.
	get_ROI = fsl.maths.Threshold()
	get_ROI.inputs.in_file = 'FS_TO_DTI_cortical.nii.gz'
	get_ROI.inputs.thresh = x-0.5
	get_ROI.inputs.args = '-uthr {}'.format(x+0.5)
	get_ROI.inputs.out_file = '{}.nii.gz',format(Freesurfer_Regions_list[index])
	get_ROI.run()

	#get volume
	current_ROI_file='{}.nii.gz',format(Freesurfer_Regions_list[index])
	get_volume_ROI = fsl.ImageStats()


