function [feature patches]= ELDA_featureExtraction( patches , image , region , params )
% feature extract at each box
scell = params.scell;
[imgH,imgW,ch]=size(image); 

feature = [];
parfor n=1:size(patches,1)   
    box = round(patches(n,1:4));
    if ch == 1
        im = image(box(2):box(4),box(1):box(3));
    elseif ch == 3
        im = image(box(2):box(4),box(1):box(3),:);
    end
    
    %% Hog for patches
    im = imResample(im2single(im),params.norm_size)/255;
    H = hog(im,scell,9);       
    sz = size(H,1)*size(H,2)*size(H,3);
    feature(n,:) = reshape(H,[1  sz]);     
end