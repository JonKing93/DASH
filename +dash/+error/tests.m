function[] = tests
%% dash.error.tests  Unit tests for the dash.error package
% ----------
%   dash.error.tests
%   Runs the tests. If successful, exits silently. If unsuccessful, throws
%   an error at the first failed test.
% ----------
%
% <a href="matlab:dash.doc('dash.error.tests')">Documentation Page</a>

notEnoughInputs;
tooManyInputs;
tooManyOutputs;

end

function[] = notEnoughInputs

try
    dash.error.notEnoughInputs;
    error('did not fail');
catch ME
    assert(isequal(ME.identifier, 'MATLAB:minrhs'), 'id');
    assert(isequal(ME.message, 'Not enough input arguments'), 'message');
end

end
function[] = tooManyInputs

try
    dash.error.tooManyInputs;
    error('did not fail');
catch ME
    assert(isequal(ME.identifier, 'MATLAB:TooManyInputs'), 'id');
    assert(isequal(ME.message, 'Too many input arguments.'), 'message');
end

end
function[] = tooManyOutputs

try
    dash.error.tooManyOutputs;
    error('did not fail');
catch ME
    assert(isequal(ME.identifier, 'MATLAB:TooManyOutputs'), 'id');
    assert(isequal(ME.message, 'Too many output arguments.'), 'message');
end

end