# ELDAtracking
Exemplar-based detectors for visual tracking

Code to accompany the paper:
  Robust Visual Tracking Using Exemplar-based Detectors
  Changxin Gao, Feifei Chen, Jin-Gang Yu, Rui Huang, Nong Sang
  IEEE T CSVT.

#  Prepares 

1 download tracker_benchmark_v1.0 (http://cvlab.hanyang.ac.kr/tracker_benchmark/benchmark_v10.html)

2 download piotr_toolbox (http://vision.ucsd.edu/~pdollar/toolbox/doc/index.html)

#   Usage   

1 Add path of racker_benchmark_v1.0, e.g., addpath(genpath('tracker_benchmark_v1.0'))

2 Add path of piotr_toolbox, e.g., addpath(genpath('piotr_toolbox'))

3 run. demo.m gives an example to use ELDA tracker.

#  Dataset  

Dataset can be downloaded from: http://cvlab.hanyang.ac.kr/tracker_benchmark/datasets.html

#   Note   

We give a initial off-line background model, you can download the mat-file on (https://drive.google.com/file/d/0B5MAorWzbBMpT1IwMERsYW4zcGc/view?usp=sharing). You can also calculate it for yourself, or you can set the "backgroundupdatelabel=1" not to use the offline information.

We have many labels to "select" some elements of our method, and your can assemble them for yourself. 

To easily evalue the different types of features, hog features are extracted at each patches, without using the acceleration manner. You can simiply change the feature type in 'ELDA_featureExtraction.m'. 

The bounding box results in our paper can be downloaded by : https://drive.google.com/file/d/0B5MAorWzbBMpTFBFS0QxcmVheG8/view?usp=sharing

The project page: https://sites.google.com/site/changxingao/elda

#   Cite
@article{gao2016robust,   
title={Robust Visual Tracking Using Exemplar-based Detectors},   
  author={Gao, Changxin and Chen, Feifei and Yu, Jin-Gang and Huang, Rui and Sang, Nong},   
  journal={IEEE Transactions on Circuits and Systems for Video Technology},   
  volume={27},   
  number={2},   
  pages={300--312},   
  year={2016},   
  publisher={IEEE}   
}   


If you have any questions, please contact me: cgao@hust.edu.cn
