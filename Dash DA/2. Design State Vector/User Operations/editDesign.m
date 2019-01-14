function[design] = editDesign( design, var, dim, dimType, index, varargin )

% Use all indices if unspecified
if ~exist('index','var')
    index = 'all';
end

% State dimension
if strcmpi(dimType, 'state')
    
    % Parse inputs
    [takeMean, nanflag] = parseInputs( varargin, {'mean','nanflag'},{false,'includenan'},{'b',{'omitnan','includenan'}} );
    
    % Edit state dimension
    design = stateDimension( design, var, dim, index, takeMean, nanflag );
    
% Ensemble dimension
elseif strcmpi(dimType, 'ens')
    
    % Parse inputs
    [seq, mean, nanflag, ensMeta] = parseInputs( varargin, {'seq','mean','nanflag','meta'}, ...
                                 {0,0,'includenan',NaN}, {{},{},{'omitnan','includenan'},{}} );
    
    % Edit ensemble dimension
    design = ensDimension( design, var, dim, index, seq, mean, nanflag, ensMeta );

% Error
else
    error('Unrecognized dimension type.');
end

end