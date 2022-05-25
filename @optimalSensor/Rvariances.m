function[R] = Rvariances(obj)

R = obj.R;
if obj.Rtype==1
    R = diag(R);
end

end