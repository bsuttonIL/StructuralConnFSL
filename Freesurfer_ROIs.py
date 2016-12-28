#Creates ROI masks fom Freesurfer parcellation (which has previous been transformed to DTI Space)

import os
import nipype.interfaces.fsl as fsl
import csv
#from ConfigParser import ConfigParser as CFP

#get parcellation number from connectome config file
#get_config=CFP()
#get_config.readfp(open('{}/connectome_variables.cfg'.format(os.environ['SCRIPTS_DIR'])))
#parcellation_num=int(get_config.get('PARC_SCHEMES','parcellation_number'))
#parcellation_labels_file=get_config.get('PARC_SCHEMES','parcellation_labels_file')
parcellation_num = int(os.environ['parcellation_number'])
parcellation_labels_file = os.environ['parcellation_labels_file']



Freesurfer_Regions_dict = {}
Freesurfer_Regions_list=[]

with open('{}/{}'.format(os.environ['SCRIPTS_DIR'],parcellation_labels_file), 'r') as f:
	for line in range(parcellation_num):
		current_line = f.readline()
		if line == parcellation_num-1:
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


ROI_volumes_csv=[]

#create each ROI niftii file
for index in range(parcellation_num):           # index goes 1:68
	# print 'Region Number {}'.format(index+1)
	x = Freesurfer_Regions_dict[Freesurfer_Regions_list[index]]
	get_ROI = fsl.maths.Threshold()
	get_ROI.inputs.in_file = 'FS_to_DTI.nii.gz'
	get_ROI.inputs.thresh = x-0.5
	get_ROI.inputs.args = '-uthr {}'.format(x+0.5)
	get_ROI.inputs.out_file = '{}.nii.gz'.format(Freesurfer_Regions_list[index])
	get_ROI.run()

	#get volume
	current_ROI_file='{}.nii.gz'.format(Freesurfer_Regions_list[index])
	get_volume_ROI = fsl.ImageStats(in_file=current_ROI_file, op_string='-V > ROI_volumes.txt')
	get_volume_ROI.run()

	roi_volumes_line=[Freesurfer_Regions_list[index]]
	with open('ROI_volumes.txt', 'r') as f:
		lines=f.readlines()
		line=lines[0].split()
	roi_volumes_line.append(line[0])
	ROI_volumes_csv.append(roi_volumes_line)

with open('ROI_Volumes.csv', 'w') as f:
	writer = csv.writer(f)
	writer.writerows(ROI_volumes_csv)
