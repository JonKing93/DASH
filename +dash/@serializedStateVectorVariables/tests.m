function[] = tests
%% dash.serializedStateVectorVariables  Unit tests for the serializedStateVectorVariables class
% ----------
%   dash.serializedStateVectorVariables.tests
%   Runs the unit tests for the serializedStateVectorVariables class. If
%   successful, exits silently. If tests fail, throws an error at the first
%   failed test.
% ----------
%
% <a href="matlab:dash.doc('dash.serializedStateVectorVariables.tests')">Documentation Page</a>

tests = {
    'empty constructor'
    'no dimensions'

    'sequences'
    'omitnan',
    'NaN mean size',
    'No NaN mean size',
    'mixed convertFunctions',
    'empty indices',
    'filled indices',
    'mixed indices',
    'ens, empty mean indices',
    'ens, filled mean indices',
    'ens, mixed mean indices',
    'ens, empty sequence indices',
    'ens, filled sequence indices',
    'ens, mixed sequence indices',
    ''




end