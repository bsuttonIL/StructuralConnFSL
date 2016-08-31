import os
with open('masks.txt', 'w') as f:
	for i in range(68):
		f.write('{}/ROI_{}.nii.gz\n'.format(os.environ['RESDIR'], i+1))

