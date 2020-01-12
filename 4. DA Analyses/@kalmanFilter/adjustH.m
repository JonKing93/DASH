function[F] = adjustH( F, reconstruct )
% Adjust H indices in PSMs to account for partially reconstructed ensemble

reconIndex = find( reconstruct );
for s = 1:numel(F)
    [~, F{s}.H] = ismember( F{s}.H, reconIndex );
end

end