classdef dash
    %% Contains various utility functions
    
    
    methods (Static)
        
        % Global data for dimension names
        names = dimensionNames;
        
        % String scalar or character row vector
        tf = isstrflag( input );
        
        % String list
        tf = isstrlist( input );
        
        % Last non-trailing singleton
        file = checkFileExists(file);
        
        assertStrFlag(input, name);
        assertStrList(input, name);
        assertNumericVectorN(input, N, name);
        assertPositiveIntegers(input, allowNaN, allowInf, name);
        
        indices = equallySpacedIndices(indices);
        
    end
    
end
        