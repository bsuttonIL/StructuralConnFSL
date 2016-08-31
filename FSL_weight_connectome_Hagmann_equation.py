# This script computes Hagmann/Sporns tranformation on structural connectome
# that accounts for surface volume size and total fiber length along all tracts
# between each pair of cortical ROIs

import csv
from math import log10 as log
import os

'''

Convert txt file output to csv

'''


txt_file = r"rh_volumes_stats.txt"
csv_file = r"aparc_aseg_R_volumes.csv"

with open(txt_file, 'r') as f:
	r = csv.reader(f, delimiter = '\t')
	lines = [l for l in r]

with open(csv_file, 'a') as f:
	w = csv.writer(f)
	w.writerows(lines)

txt_file = r"lh_volumes_stats.txt"
csv_file = r"aparc_aseg_L_volumes.csv"

with open(txt_file, 'r') as f:
	r = csv.reader(f, delimiter = '\t')
	lines = [l for l in r]

with open(csv_file, 'a') as f:
	w = csv.writer(f)
	w.writerows(lines)

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
		current_line = current_line[1][4:6]+'_'+current_line[1][7:]+'_volume'
		cortical_ROIS.append(current_line)

with open('aparc_aseg_R_volumes.csv', 'r') as f:
	r = csv.reader(f)
	right_volumes = [l for l in r]

with open('aparc_aseg_L_volumes.csv', 'r') as g:
	r = csv.reader(g)
	left_volumes = [l for l in r]

for item in left_volumes[0]:
	right_volumes[0].append(item)
for item in left_volumes[1]:
	right_volumes[1].append(item)

Total_volumes = right_volumes

Surface_volumes= {}

for entry in range(len(Total_volumes[0])):
	Surface_volumes[Total_volumes[0][entry]] = Total_volumes[1][entry]


# #average length per tract for each ROI-ROI pathway
# with open('64_ROI_cortex_ts.csv', 'r') as f:
# 	r = csv.reader(f)
# 	avg_tract_length = [l for l in r]


#gross number of connections between each ROI-ROI pathway
connectome_unweighted_file = 'conn_68.csv'
with open(connectome_unweighted_file, 'r') as g:
	reader = csv.reader(g)
	num_tracts = [l for l in reader]	
	#for each ROI, weight volume of ROIs
	for ROI in range(68):
		for connection in range(68):
			num_tracts[ROI][connection]= (2/(float(Surface_volumes[cortical_ROIS[ROI]])+(float(Surface_volumes[cortical_ROIS[connection]])))*((float(num_tracts[ROI][connection]))))
	
		


with open('conn68_VolumeWeighted.csv', 'w') as f:
	writer = csv.writer(f)
	writer.writerows(num_tracts) 
