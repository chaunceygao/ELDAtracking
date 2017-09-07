function [ features , infos ] = ELDA_FeaturizeImage( image , params, region )
    
    sz_width  = params.sz_width ;
    sz_height = params.sz_height ;     
    
    %% multi scale( only one scale here)    
    x_step = params.track_xy_step ;
    y_step = params.track_xy_step ;
    [X1 Y1] = meshgrid( region(1):x_step:region(3)-sz_width+1, region(2):y_step:region(4)-sz_height+1   );  
    X1 = reshape(X1,[ size(X1,1)*size(X1,2) 1] );
    Y1 = reshape(Y1,[ size(Y1,1)*size(Y1,2) 1] );
    X2 = X1 + sz_width-1;
    Y2 = Y1 + sz_height-1;
    infos = [X1 Y1 X2 Y2]; 

    [features infos] = ELDA_featureExtraction( infos , image, region, params ) ; 
end