#Weight connectomes by average volume (number of voxels in each ROI)


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
