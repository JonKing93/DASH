classdef dash
    %% Contains various utility functions
    
    
    methods (Static)
        
        % Global data for dimension names
        names = dimensionNames;
        
        % Files and paths
        path = checkFileExists(file);  
        path = unixStylePath(path);
        path = relativePath(to, from);
        
        % Input error checks
        tf = isstrflag( input );        
        tf = isstrlist( input );
        tf = isrelative( name );
        assertStrFlag(input, name);
        assertStrList(input, name);
        assertNumericVectorN(input, N, name);
        assertPositiveIntegers(input, allowNaN, allowInf, name);
        str = errorStringList(strings);
        varargout = parseInputs(inArgs, flags, defaults, nPrev);

        % Indices and start, count, stride.
        indices = equallySpacedIndices(indices);
        
        % File formats
        convertToV7_3(filename);
    end
    
end
        