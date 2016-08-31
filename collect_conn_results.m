%% Code to read in all connectome results from the MS data
% 2016-07-05
% Brad Sutton and Jorge Maldonado



%%  Get subject names from a text file
subfid = fopen('subjects_all.txt','r');

%subj_root = '/shared/mrfil-data/data/MS_Project/'
subj_root = '/Volumes/mrfil-data/data/MS_Project/'
conn_in_subj = '/Analyze/Connectome/FSL_68ROI/'
con_name = 'conn68_VolumeWeighted.csv'

%%
num_subj = 43; %50;

%% Loop through subjects
 % METS_05 has a problem - two times the number of rows
 % Exert_50_ not found.
 % METS_19 not found
 %TheraStride_04 - two times the number of rows.  
 % TheraStride_04 Was in there twice
 %TheraStride_06 - two times the number of rows
 %TheraStride_06 was in there twice
 

for ii = 1:num_subj
    subj_name = fgetl(subfid);
    M = csvread(sprintf('%s%s%s%s', subj_root,subj_name,conn_in_subj,con_name));
    %keyboard
    ConMTX(:,ii) = M(:);  
end

fclose(subfid);

xlswrite('ConnResults.xls',ConMTX)
