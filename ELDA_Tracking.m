function finalresult = ELDA_Tracking(s, exs, meanv, n, sumxxt, myparams)
% finalresult = ELDA_Tracking(s, exs, meanv, n, sumxxt, myparams)
% ELDA tracking algorithm
%
% Code to accompany the paper:
%   Exemplar-based Linear Discriminant Analysis for Robust Object Tracking
%   Changxin Gao, Feifei Chen, Jingang Yu, Nong Sang
%   Submitted to ICIP 2014
% 
% Copyright (C) 2014 Changxin Gao, Huazhong University of Science and Technology, Wuhan, China
% All rights reserved.
% Contact: Changxin Gao <cgao@hust.edu.cn>


%% read params
scell = myparams.scell;
distThresh = myparams.distThresh;
weightTWset = myparams.weightTW;
  
initbox = [s.init_rect(1,1) s.init_rect(1,2) s.init_rect(1,1)+s.init_rect(1,3)-1 s.init_rect(1,2)+s.init_rect(1,4)-1];
numFrame = s.len;

%% load first frame
img = imread(s.s_frames{1});
imsz = size(img);
if myparams.extendlabel == 1
    initbox(1) = max(1,round( initbox(1) - 0.1*(initbox(3)-initbox(1)) ) );
    initbox(2) = max(1,round( initbox(2) - 0.1*(initbox(4)-initbox(2)) ) );
    initbox(3) = min(ww,round( initbox(3) + 0.1*(initbox(3)-initbox(1)) ) );
    initbox(4) = min(hh,round( initbox(4) + 0.1*(initbox(4)-initbox(2)) ) );
end
    
%% init at the first frame
tparams = myparams;
tparams.sz_width = initbox(3)-initbox(1)+1;
tparams.sz_height = initbox(4)-initbox(2)+1;
[feature]= ELDA_featureExtraction( initbox , img , initbox, tparams );                                               

%% updating background model
if myparams.backgroundupdatelabel ~= 0
    region(1) = max( round(initbox(1) - myparams.detectRadius) , 1);
    region(2) = max( round(initbox(2) - myparams.detectRadius) , 1);
    region(3) = min( round(initbox(3) + myparams.detectRadius) , imsz(2));
    region(4) = min( round(initbox(4) + myparams.detectRadius) , imsz(1));

    [ features , res_infos ] = ELDA_FeaturizeImage( img , tparams, region ) ;
    tDist = (res_infos(:,1)+(res_infos(:,3)-res_infos(:,1)+1)/2 - ones(size(res_infos,1),1)*(initbox(1)+tparams.sz_height/2)).^2 ...
        + (res_infos(:,2)+(res_infos(:,4)-res_infos(:,2)+1)/2 - ones(size(res_infos,1),1)*(initbox(2)+tparams.sz_height/2)).^2;
    [exs sumxxt, meanv n] = ELDA_onlinecov(features(find(tDist > distThresh*distThresh),:), sumxxt, meanv, n);
end
   
    
%% LDA
setm = 0.01*diag(ones(1,size(exs,1)));
w = [];
if myparams.objectupdatelabel == 1
    w = zeros(size(feature,2),1);
else
    w = (exs+setm)\(feature - meanv)';
    if myparams.normlabel == 1
        w = normvec( w, scell );
    end
end

if myparams.weightinglabel == 1
    weightTW = weightTWset(1);
end

%% initialization
bbox = initbox;
finalresult = zeros(numFrame,4);
finalresult(1,:) = s.init_rect;

%% showing
if myparams.showlabel == 1
    I = img(initbox(2):initbox(4) , initbox(1) : initbox(3) , : );
    figure(1),imshow(I),title('Template image');
    V=hogDraw(reshape( feature, [8 8 36] ),25); figure(2); imshow(V), title('positive sample');
    Vw=hogDraw(reshape(w,[8 8 36]),25); figure(3); imshow(Vw), title('w');
end

for indframe=2:s.len
   %% read image
    im = imread( s.s_frames{indframe} );
   
   %% set detect region 
    region = bbox;
    region(1) = max( round(bbox(1) - myparams.detectRadius) , 1);
    region(2) = max( round(bbox(2) - myparams.detectRadius) , 1);
    region(3) = min( round(bbox(3) + myparams.detectRadius) , imsz(2));
    region(4) = min( round(bbox(4) + myparams.detectRadius) , imsz(1));

    %% feature extraction           
    [ features , res_infos ] = ELDA_FeaturizeImage( im , tparams, region ) ;

    %% updating background model
    if myparams.backgroundupdatelabel ~= 0
        tDist = (res_infos(:,1)+(res_infos(:,3)-res_infos(:,1)+1)/2 - ones(size(res_infos,1),1)*(bbox(1)+tparams.sz_height/2)).^2 ...
            + (res_infos(:,2)+(res_infos(:,4)-res_infos(:,2)+1)/2 - ones(size(res_infos,1),1)*(bbox(2)+tparams.sz_height/2)).^2;
        [exs sumxxt, meanv n] = ELDA_onlinecov(features(find(tDist > distThresh*distThresh),:), sumxxt, meanv, n);
    end

   %% scores  
   if myparams.weightinglabel == 1
       res_scores = features*(w*weightTW');
   else
       res_scores = features*w;
   end

   %% combining results
    res_scores = sum(res_scores,2);

   %% find final position
    top_indexes = ELDA_NonMaximumSuppression( res_infos( :, 1:4 ) , res_scores , tparams.nms_os_threshold ) ;
    res_infos = res_infos( top_indexes(1,1) , : ) ;

   %% training for next frame
    bbox = res_infos(1,1:4);  
    finalresult(indframe,:) = [bbox(1) bbox(2) bbox(3)-bbox(1)+1 bbox(4)-bbox(2)+1]; 
    
    %% show results
    if myparams.showlabel == 1
        figure(4)        
        if length(size(im)) == 2
            im = cat(3,im,im,im);
        end 
        imshow(im);
        title(['frame #' int2str(indframe) ]);
        rectangle('Position', finalresult(indframe,:),'Curvature', [0,0], 'LineWidth',3,'EdgeColor','r');
        Vw=hogDraw(reshape( features( top_indexes(1,1) , : ) , [8 8 36]),25); figure(2); imshow(Vw), title('feature');
        Vw=hogDraw(reshape( w(:,size(w,2)),[8 8 36]),25); figure(3); imshow(Vw), title('w');            
    end

   %% update object model
    if myparams.objectupdatelabel ~= 0 
        tempf = features(top_indexes(1,1) , :);
        tempw = (exs+setm)\(tempf - meanv)';
        if myparams.normlabel == 1
            tempw = normvec( tempw, scell );
        end
        wind = mod(indframe-2,myparams.timewindow)+2;
        if myparams.weightinglabel == 1
            weightSS = tanh( ( tempf * w(:,1) ) / ( feature * w(:,1) ) );
            weightTW(2:min(indframe-1,myparams.timewindow)+1) = weightTWset(myparams.timewindow+1-wind+1 : myparams.timewindow+1-wind+1 + min(indframe-1,myparams.timewindow)-1) ;
        else
            weightSS = 1;
        end
        w(:,wind) = weightSS*tempw;
    end
end

if myparams.showlabel == 1
    showresult(finalresult,s.path);
end
end



function wvec = normvec( w, scell )
w = reshape(w,[8 8 36]);
for i = 1:8
    for j = 1:8
        tmp = reshape(w(i,j,:),[1 36]) ;
        w(i,j,:) = tmp/norm(tmp);
    end
end
wvec = reshape(w,[8*8*36 1]);
end
        
        