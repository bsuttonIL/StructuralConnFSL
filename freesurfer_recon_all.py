
from ConfigParser import ConfigParser as CFP
import os
import csv
from nipype.interfaces.freesurfer import ReconAll

#get parcellation number from connectome config file
get_config=CFP()
get_config.readfp(open('freesurfer_variables.cfg'))
T1_loc=get_config.get('DEFAULT_VARIABLES','T1_location')
T1_name=get_config.get('DEFAULT_VARIABLES','T1_name')
fs_log=get_config.get('DEFAULT_VARIABLES','log_freesurfer_recon_all')
fs_sub_dir=get_config.get('DEFAULT_VARIABLES','subjects_dir')

subjects=[]
with open('subjects.txt', 'r') as f:
	all_lines=f.readlines()
	for line in all_lines:
		if '\n' in line:
			subjects.append(line[:-1])
		else:
			subjects.append(line)

for sub in subjects:
	os.chdir(T1_loc)
	os.chdir(sub)

	reconall = ReconAll()
	reconall.inputs.subject_id='sub_{}'.format(sub)
	reconall.inputs.directive='all'
	reconall.inputs.T1_files=T1_name
	reconall.inputs.subjects_dir=fs_sub_dir
	reconall.run()

	print 'subject {} finished recon-all!!!'.format(sub)



