function[out] = preallocateOutput(obj, N)
%% Preallocates the output structure for an optimal sensor test

% Site rankings
out.best = NaN(N,1);
out.rank = NaN(obj.nSite, N);

% Metric
if obj.return_metric.initial
    out.metric.initial = NaN(1, obj.nEns);
end
if obj.return_metric.updated
    out.metric.updated = NaN(N, obj.nEns);
end
if obj.return_metric.final
    out.metric.final = NaN(1, obj.nEns);
end

end
