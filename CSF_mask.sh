#!/bin/bash

#create CSF mask for tractography

fslmaths FS_to_DTI.nii.gz -thr 3.5 -uthr 4.5 tmp1.nii.gz
fslmaths FS_to_DTI.nii.gz -thr 13.5 -uthr 15.5 tmp2.nii.gz
fslmaths tmp1.nii.gz -add tmp2.nii.gz tmp1.nii.gz
rm tmp2.nii.gz
fslmaths FS_to_DTI.nii.gz -thr 23.5 -uthr 24.5 tmp2.nii.gz
fslmaths tmp1.nii.gz -add tmp2.nii.gz tmp1.nii.gz
rm tmp2.nii.gz
fslmaths FS_to_DTI.nii.gz -thr 30.5 -uthr 31.5 tmp2.nii.gz
fslmaths tmp1.nii.gz -add tmp2.nii.gz tmp1.nii.gz
rm tmp2.nii.gz
fslmaths FS_to_DTI.nii.gz -thr 42.5 -uthr 44.5 tmp2.nii.gz
fslmaths tmp1.nii.gz -add tmp2.nii.gz tmp1.nii.gz
rm tmp2.nii.gz
fslmaths FS_to_DTI.nii.gz -thr 62.5 -uthr 63.5 tmp2.nii.gz
fslmaths tmp1.nii.gz -add tmp2.nii.gz tmp1.nii.gz
rm tmp2.nii.gz
fslmaths FS_to_DTI.nii.gz -thr 71.5 -uthr 72.5 tmp2.nii.gz
fslmaths tmp1.nii.gz -add tmp2.nii.gz tmp1.nii.gz
rm tmp2.nii.gz
fslmaths FS_to_DTI.nii.gz -thr 74.5 -uthr 76.5 tmp2.nii.gz
fslmaths tmp1.nii.gz -add tmp2.nii.gz CSFmask.nii.gz
rm tmp*
