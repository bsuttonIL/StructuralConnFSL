
import csv
import os
from ConfigParser import ConfigParser as ConfigParser

#get parcellation number from connectome config file
get_config=CFP()
parcellation_num=int(get_config.get('PARC_SCHEMES','parcellation_number'))
pacellation_labels_file=get_config.get('PARC_SCHEMES','parcellation_labels_file')
cortical_ROIS_list=[]

#put info in labels file into a python list
with open('{}/{}'.format(os.environ['CONN_DIR'],parcellation_labels_file), 'r') as f:
	all_lines=f.readlines()
	for lines in all_lines:
		cortical_ROIS_list.append(lines.split()[1])

#create nested list with ROI labels in first row to prepare to write to CSV file
with open('conn{}_VolumeWeighted.csv'.format(parcellation_num), 'r') as f:
	r = csv.reader(f)
	newlines = [l for l in r]
	newlines.insert(0,[])
	for i in range(parcellation_num):
		newlines[0].append(cortical_ROIS_list[i])

#write labelled connectome with ROIs in first row to CSV file
with open('conn{}_VolumeWeighted_headers.csv'.format(parcellation_num), 'a') as f:
	w = csv.writer(f)
	w.writerows(newlines)
	

