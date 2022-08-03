function[] = tests
%% dash.warning.tests  Unit tests for the dash.warning package
% ----------
%   dash.warning.tests
%   Runs the tests for the dash.warning package. If successful, exits
%   silently. Otherwise, throws an error at the first failed test.
% ----------
%
% <a href="matlab:dash.doc('dash.warning.tests')">Documentation Page</a>

state;

end

function[] = state

id = 'DASH:warning:id';
current = warning('query', id).state;
tests = {
    'on'
    'off'
    'error'
    };


try
    for t = 1:size(tests,1)
        reset = dash.warning.state(tests{t,1}, id);
        state = warning('query', id).state;

        assert(strcmp(state, tests{t,1}), 'altered state');
        delete(reset);
        state = warning('query', id).state;
        assert(strcmp(state, current), 'reset state');
    end
catch cause
    ME = MException('test:failed', '%.f: %s', t, tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end