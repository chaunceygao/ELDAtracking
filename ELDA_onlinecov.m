function [exs newsumxxt newmeanv newn] = ELDA_onlinecov(features, sumxxt, meanv, n)
if n==0
    newsumxxt = features'*features;
    newn = size(features,1);
    newmeanv = sum(features)/newn;
else
    newsumxxt = sumxxt + (features'*features);
    newn = n + size(features,1);
    newmeanv = (meanv*n + sum(features))/newn;    
end
exs = (newsumxxt - newn*newmeanv'*newmeanv)/(newn-1);