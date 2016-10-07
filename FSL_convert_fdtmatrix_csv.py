import csv
import os
from ConfigParser import ConfigParser as CFP

#get parcellation number from connectome config file
get_config=CFP()
get_config.readfp(open('{}/connectome_variables.cfg'.format(os.environ['SCRIPTS_DIR'])))
parcellation_num=int(get_config.get('PARC_SCHEMES','parcellation_number'))

with open('{}/fdt_network_matrix'.format(os.environ['RESDIR']), 'r') as f:
	lines = [l.split() for l in f]
	

with open('conn_{}.csv'.format(parcellation_num), 'a') as f:
	writer = csv.writer(f)
	writer.writerows(lines)



