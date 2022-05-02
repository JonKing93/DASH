try
    for t = 1:size(tests,1)
        shouldFail = ~tests{t,2};
        if shouldFail
            try
                %...
                error('test:succeeded','did not fail');
            catch ME
                if strcmp(ME.identifier, 'test:succeeded')
                    throw(ME);
                end
            end
            assert(contains(ME.identifier, header), 'invalid error');
            
        else
            %...
            % assert(output)
        end
    end
catch cause
    ME = MException('test:failed', '%.f: %s', t, tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end