function[iA, iB] = matchingMetaIndex( metaA, metaB )

% Replace NaN elements with 0
if isnumeric(metaA)
    metaA( isnan(metaA) ) = 0;
end
if isnumeric(metaB)
    metaB( isnan(metaB) ) = 0;
end

% Replace NaT elements with 0
if isdatetime(metaA)
    metaA( isnat(metaA) ) = datetime(0,0,0);
end
if isdatetime(metaB)
    metaB( isnat(metaB) ) = datetime(0,0,0);
end

% Get the intersecting rows
[~, iA, iB] = intersect( metaA(:,:), metaB(:,:), 'rows', 'stable' );

end