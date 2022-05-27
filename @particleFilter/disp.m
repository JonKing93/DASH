function[] = disp(obj)
%% particleFilter.disp  Displays a particle filter in the console
% ----------
%   obj.disp
%   Displays a particle filter object in the console. If the object is
%   scalar, displays the label (if there is one). Also displays the current
%   status of the observations, estimates, uncertainties, and prior.
%   Displays assimilation sizes as they are set. Also lists the weighting
%   scheme used by the particle filter.
%
%   If the object is an array, displays the array size. If any of the
%   objects in the array have labels, displays the labels. Any object
%   without a label is listed as "<no label>". If the array is empty,
%   declares that the array is empty.
% ----------
%   Outputs:
%       Displays the particle filter object in the console.
%
% <a href="matlab:dash.doc('particleFilter.disp')">Documentation Page</a>

% Get class documentation link
link = '<a href="matlab:dash.doc(''particleFilter'')">particleFilter</a>';

% Display the filter
obj.dispFilter(link);

% If scalar, also display the weighting Scheme
if isscalar(obj)
    if obj.weightType==0
        details = 'Bayesian';
    else
        details = sprintf('Best %.f particles', obj.weightArgs{1});
    end
    fprintf('    Weighting scheme: %s\n\n', details);
end

end