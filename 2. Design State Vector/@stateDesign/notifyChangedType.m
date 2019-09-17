function[] = notifyChangedType( obj, v, d, cv )
% v: The variable index
%
% d: The dimension index
%
% cv: Optional coupled variables

% Only notify if there are coupled variables
if ~isempty(cv)

    % Get plurals for dimensions and variables
    ds = "s";
    dverb = "are";
    if numel(d) == 1
        ds = "";
        dverb = "is";
    end

    cs = "s";
    cgroup = "these";
    if exist('cv','var') && numel(cv)==1
        cs = "";
        cgroup = "this";
    end

    vs = "";
    vgroup = "this";
    if exist('cv', 'var')
        vs = cs;
        vgroup = cgroup;
    end

    line1 = [sprintf('Dimension%s ',ds), sprintf('%s, ', obj.var(v).dimID(d)), ...
        sprintf('\b\b %s changing type for variable %s.\n', dverb, obj.varName(v)) ];

    line2 = '';
    if exist('cv', 'var')
        line2 = [sprintf('Coupled variable%s ',cs), sprintf('%s, ', obj.varName(cv)), ...
            sprintf('\b\b will also be altered.\n')];
    end

    line3 = sprintf('Deleting sequence and mean design specifications for %s variable%s.\n\n', ...
                     vgroup, vs );


    fprintf([line1, line2, line3]);
end

end