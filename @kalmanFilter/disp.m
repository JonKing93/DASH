function[] = disp(obj)
%% kalmanFilter.disp  Displays a particle filter in the console
% ----------
%   obj.disp
%   Displays a particle filter object in the console. If the object is
%   scalar, displays the label (if there is one). Also displays the current
%   status of the observations, estimates, uncertainties, and prior.
%   Displays assimilation sizes as they are set. Lists covariance options
%   implemented by the filter. Lists output options for the filter.
%
%   If the object is an array, displays the array size. If any of the
%   objects in the array have labels, displays the labels. Any object
%   without a label is listed as "<no label>". If the array is empty,
%   declares that the array is empty.
% ----------
%   Outputs:
%       Displays the Kalman filter object in the console.
%
% <a href="matlab:dash.doc('kalmanFilter.disp')">Documentation Page</a>

% Get class documentation link
link = '<a href="matlab:dash.doc(''kalmanFilter'')">kalmanFilter</a>';

% Get width of displayed labels
returning = "Returning";
covariance = "Covariance";
labels = returning;
if ~isempty(obj.inflationFactor) || ~isempty(obj.wloc) || ~isempty(obj.Cblend) || ~isempty(obj.Cset)
    labels = [labels, covariance];
end
width = max(strlength(labels));

% Display data inputs and sizes
width = obj.dispFilter(link, width);

% Only add details if scalar
if ~isscalar(obj)
    return
end

% Get formats for labels and secondary lists
labelFormat = sprintf('    %%%.fs:\\n', width);
nSpaces = width - 1;
pad = repmat(' ', 1, nSpaces);
listFormat = sprintf('%s%%s\\n', pad);

% Covariance adjustments
if ~isempty(obj.inflationFactor) || ~isempty(obj.wloc) || ~isempty(obj.Cblend) || ~isempty(obj.Cset)
    fprintf(labelFormat, covariance);

    info = ["Inflation", "Localization", "Blending","Directly set by user"];
    fields = ["inflationFactor", "wloc", "Cblend","Cset"];
    whichFields = ["whichFactor","whichLoc","whichBlend","whichSet"];
    for f = 1:numel(fields)
        if ~isempty(obj.(fields(f)))
            if ~isempty(obj.(whichFields(f)))
                info(f) = strcat(info(f), " (time dependent)");
            end
            fprintf(listFormat, info(f));
        end
    end
    fprintf('\n');
end

% Output options
fprintf(labelFormat, returning);
fprintf(listFormat, 'Mean');
if obj.returnDeviations
    fprintf(listFormat, 'Deviations');
end
if any(obj.calculationTypes==0)
    fprintf(listFormat, 'Variance');
end

k = find(obj.calculationTypes==1);
if ~isempty(k)
    nPercs = numel(obj.calculations{k}.percentages);
    info = sprintf('Percentiles (%.f)', nPercs);
    fprintf(listFormat, info);
end

k = find(obj.calculationTypes==2);
if ~isempty(k)
    names = obj.calculationNames(k);
    userNames = eraseBetween(names, 1, strlength(obj.indexHeader));
    list = dash.string.list(userNames);

    if numel(k)==1
        info = sprintf('Index: %s', list);
    else
        info = sprintf('Indices: %s', list);
    end
    fprintf(listFormat, info);
end
fprintf('\n');

end