function[] = info( obj, varNames, dims, showMeta )
%% Displays information about a sate vector design.
%
% obj.disp
% Outputs information on every dimension of every variable in a state
% vector design.
%
% obj.disp( varNames )
% Outputs information on every dimension for specified variables in a state
% vector design.
%
% obj.disp( varNames, dims )
% Outputs information on specific dimensions for specified variables.
%
% obj.disp( varNames, dims, showMeta )
% Specify whether to display metadata for each dimension.
%
% ----- Inputs -----
%
% obj: A stateDesign object.
%
% varNames: A set of variable names. Either a character row vector,
%           cellstring, or string vector.
%
% dims: A list of dimension names. Either a character row vector,
%       cellstring, or string vector.
%
% showMeta: A scalar logical. Specifies whether to display dimension
%           metadata.

% ----- Written By -----
% Jonathan king, University of Arizona, 2019

% Error check the inputs. Get the indices of the variables and dimensions
[v, dim] = setup( obj, varNames, dims, showMeta );

% Display design name and variables header
fprintf('State Vector Design: %s\n', obj.name );
fprintf('Variables:\n');

% For each variable
for k = 1:numel(v)
    var = obj.var( v(k) );
    
    % Name, gridfile
    fprintf('\t%s\n', obj.var(v).name );
    fprintf( '\t\tGridfile: %s\n', var.file );
    
    % Coupled variables, overlap status, dimension header
    cv = find( obj.isCoupled(v(k),:) );
    cv = cv(cv~=v(k));   % Remove self
    fprintf([ '\t\tCoupled Variables: ', sprintf('%s, ', obj.varName(cv)), '\b\b\n' ]);
    
    overlap = "Forbidden";
    if obj.overlap(v(k))
        overlap = "Allowed";
    end
    fprintf('\t\tEnsemble overlap: %s\n', overlap);
    
    fprintf('\t\tDimensions:\n');
    
    % For each dimension
    for j = 1:numel(dim)
        d = dim(j);
        
        % Name, size, type, mean, nanflag
        fprintf('\t\t\t%s\n', var.dimID(d));
        fprintf('\t\t\t\tNumber of indices: %0.f\n', numel(var.indices{d}) );
        
        dimType = "State";
        if ~var.isState(d)
            dimType = "Ensemble";
        end
        fprintf('\t\t\t\tType: %s', dimType);

        takeMean = "True";
        if ~var.takeMean(d)
            takeMean = "False";
        end
        fprintf('\t\t\t\tMean: %s', takeMean);
        
        if var.takeMean
            fprintf('\t\t\t\tNaN Flag: %s\n', var.nanflag{d} );
        end
        
        % If an ensemble dimension, show sequence and mean indices
        if ~var.isState(d) 
            if ~isequal( var.seqDex{d}, 0 )
                fprintf( ['\t\t\t\tSequence Indices: ', sprintf('%i, ',var.seqDex{d}), '\b\b\n'] );
            end
            
            if ~isequal( var.meanDex{d}, 0 )
                fprintf( ['\t\t\t\tMean Indices: ', sprintf('%i, ', var.meanDex{d}), '\b\b\n'] );
            end
        end

        % Show metadata if desired
        if showMeta
            fprintf('\t\t\t\t%s Index Metadata:\n', dimType);
            disp( var.meta.(var.dimID(d))(var.indices{d},:) );
            fprintf('\b');
            
            if ~isempty( var.seqMeta{d} ) && ~isnan( var.seqMeta{d} )
                fprintf('\t\t\t\tSequence Metadata:\n');
                disp( var.seqMeta{d} );
                fprintf('\b');
            end
        end
        
        % Extra space for next line
        fprintf('\n');
    end   
end

end

function[v,d] = setup( obj, varNames, dims, showMeta )

v = obj.findVarIndices( varNames );
d = obj.findDimIndices( v(1), dims );

if ~islogical(showMeta) || ~issscalar(showMeta)
    error('showMeta must be a scalar logical.');
end

end