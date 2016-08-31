
import csv
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
		Hagmann_Order[current_line[0]]=current_line[1]
		cortical_ROIS.append(current_line[1])



with open('conn68_VolumeWeighted.csv', 'r') as f:
	r = csv.reader(f)
	newlines = [l for l in r]
	newlines.insert(0,[])
	newlines[0].append(0)
	for i in range(68):
		if i < 67:
			newlines[0].append(0)
		newlines[0][i] = Hagmann_Order[str(i+1)]

with open('conn68_VolumeWeighted_headers.csv', 'a') as f:
	w = csv.writer(f)
	w.writerows(newlines)
	

