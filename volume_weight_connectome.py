#Written by PAUL SHRAP on 10-4-2016
#Weight connectomes by average volume (number of voxels in each ROI)

#from ConfigParser import ConfigParser as CFP
import os
import csv

#get parcellation number from connectome config file
#get_config=CFP()
#get_config.readfp(open('{}/connectome_variables.cfg'.format(os.environ['SCRIPTS_DIR'])))
#parcellation_num=int(get_config.get('PARC_SCHEMES','parcellation_number'))
parcellation_num = int(os.environ['parcellation_number'])

with open('ROI_Volumes.csv', 'r') as f:
	reader=csv.reader(f)
	Voxel_nums=[line for line in reader]



#gross number of connections between each ROI-ROI pathway
connectome_unweighted_file = 'conn_{}.csv'.format(parcellation_num)
with open(connectome_unweighted_file, 'r') as g:
	reader = csv.reader(g)
	num_tracts = [l for l in reader]
	#for each ROI, weight volume of ROIs
	for ROI in range(parcellation_num):
		for connection in range(parcellation_num):
			num_tracts[ROI][connection]= (2/(float(Voxel_nums[ROI][1])+(float(Voxel_nums[connection][1])))*((float(num_tracts[ROI][connection]))))


with open('conn{}_VolumeWeighted.csv'.format(parcellation_num), 'w') as f:
	writer = csv.writer(f)
	writer.writerows(num_tracts)
