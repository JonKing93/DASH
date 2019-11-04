function[subDraws] = removeOverlap( obj, subDraws, cv )
% Remove overlapping draws for a set of coupled variables

% Iterate through all the variables (because
% the variables may have different spacing in different dimensions).
for v = 1:numel(cv)
    var = obj.var( cv(v) );
    
    % Get the data indices from which values are loaded in the .grid file
    [dataIndex, nSeq] = var.dataIndices( var, subDraws );
    
    % Get the indices of repeated / overlapping sampling indices. Overwrite
    % overlapping draws with NaN and move to the end of the array.
    [~, uniqIndex] = unique( dataIndex, 'rows', 'stable' );
    overlap = (1:size(dataIndex,1))';
    overlap = overlap( ~ismember(overlap, uniqIndex) );

    badDraw = unique( ceil( overlap / nSeq ) );
    subDraws( badDraw, : ) = NaN;

    failed = ismember( 1:size(subDraws,1), badDraw );
    subDraws = [ subDraws(~failed,:); subDraws(failed,:) ];
end

end