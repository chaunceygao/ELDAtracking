function top_indexes = ELDA_NonMaximumSuppression( patches , scores , os )
% NMS modified by the code (esvm_nms.m) in the project of Exemplar-SVM
% (https://github.com/quantombone/exemplarsvm)
if isempty( patches)
    top_indexes = [] ;
    return ;
end

x1 = patches( :,1 ) ;
y1 = patches( :,2 ) ;
x2 = patches( :,3 ) ;
y2 = patches( :,4 ) ;

patches_area = (x2-x1+1) .* (y2-y1+1) ;

[ ~ , indexes ] = sort( scores ) ;  % ascending

top_indexes = zeros( length(scores) , 1 ) ;
counter = 0 ;

while ~isempty( indexes ) 
    last = length(indexes) ;
    cur_ind = indexes( last ) ;
    
    counter = counter+1 ;
    top_indexes(counter) = cur_ind ;
    
    if last == 1 
        break ;
    end
    other_indexes = indexes( 1:last-1) ;
    
    xx1 = max( x1( cur_ind ) , x1( other_indexes ) ) ;
    xx2 = min( x2( cur_ind ) , x2( other_indexes ) ) ;
    yy1 = max( y1( cur_ind ) , y1( other_indexes ) ) ;
    yy2 = min( y2( cur_ind ) , y2( other_indexes ) ) ;
    
    w = max( 0 , xx2-xx1+1) ;
    h = max( 0 , yy2-yy1+1) ;
    
    overlap_area = ( w.*h ) ; 
    
    overlap_ratio = max( overlap_area ./ patches_area( other_indexes ) , overlap_area/patches_area( cur_ind ) ) ;
    
    indexes( [ last ; find( overlap_ratio > os ) ] ) = [] ;
end

top_indexes = top_indexes( 1:counter ) ;

end