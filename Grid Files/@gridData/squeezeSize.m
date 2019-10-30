function[siz] = squeezeSize( siz )
%% Removes trailing singleton dimensions.

lastNS = find( siz~=1, 1, 'last' );

if isempty( lastNS )
    siz = 1;
else
    siz =  siz( 1:lastNS );
end

end