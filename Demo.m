% demo, usage of ELDA Tracking
clear;
% close all
% matlabpool(3)
addpath(genpath('E:\code\MATLAB toolbox\piotr_toolbox\toolbox'))
addpath(genpath('E:\Project\tracking\benchmark\tracker_benchmark_v1.0'))
%% mex compile 
% cd ./cp/
% compile
% cd ../

%% set params
load params
% myparams.savelabel = 0;                 % 1 save result                 0 do not save
% myparams.extendlabel = 0;               % 1 extended                    0 no extended 
% myparams.normlabel = 0;                 % 1 normalize                   0 no normalize
% myparams.showlabel = 1;                 % 1 show results                0 do not show
% myparams.backgroundupdatelabel = 2;     % 2 update both                 1 only online       0 only offline
% myparams.objectupdatelabel = 2;         % 2 update both                 1 only short-term   0 only long-term
% myparams.weightinglabel = 1;            % 1 weight object models        0 do not weight


%% load  Covariance matrix
% covPASCALVOC is some offline information of nagatives, includes exs (covariance
% matrix),sumxxt (sum(x*x')), meanv (means of off), and n (number of samples)
% You can train it for your self, or set the "backgroundupdatelabel=1" to
% only use the only negatives.
if myparams.backgroundupdatelabel == 1
    exs = [];
    sumxxt = [];
    meanv = [];
    n = 0;
else
    load covPASCALVOC
end

%% load seq
% we save seqs data using the function and dataset provided by the benchmark work
% http://visual-tracking.net/
load seqTracking
index = 1:length(seqs);
    
CLE = [];
%% Trakcing
for ind = 1:length(index)
    
    seq = seqs{index(ind)};
    pathAnno = './anno/';
    seq.rect_anno = dlmread([pathAnno seq.name '.txt']);
    %seq.startFrame
    seq.init_rect = seq.rect_anno(1,:); 
    seq.len = seq.endFrame - seq.startFrame + 1;
    seq.s_frames = cell(seq.len,1);
    nz	= strcat('%0',num2str(seq.nz),'d'); %number of zeros in the name of image
    for i=1:seq.len
        image_no = seq.startFrame + (i-1);
        id = sprintf(nz,image_no);
        seq.s_frames{i} = strcat(seq.path,id,'.',seq.ext);
    end
    %% Trakcing
    % HoG feature on each position
    results = ELDA_Tracking(net, seq, exs, meanv, n, sumxxt, myparams);  
%     % HoG feature, fast version
%     results = ELDA_Tracking_hog_fast(net, seq, exs, meanv, n, sumxxt, myparams);
%     % raw pixel feature in each color channel
%     results = ELDA_Tracking_raw(net, seq, exs, meanv, n, sumxxt, myparams);
%     % color histogram feature in 3-level pyramid
%     results = ELDA_Tracking_hist(net, seq, exs, meanv, n, sumxxt, myparams);
        
    %% save results
    if myparams.savelabel == 1
        savepath = '.\rlt\';
        filename = [ savepath seq.name '_ELDA.mat'];
        save(filename, 'results') 
    end
end
