import csv
import os

with open('{}/fdt_network_matrix'.format(os.environ['RESDIR']), 'r') as f:
	lines = [l.split() for l in f]
	

with open('conn_68.csv', 'a') as f:
	writer = csv.writer(f)
	writer.writerows(lines)
