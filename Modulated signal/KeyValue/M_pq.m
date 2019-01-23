%X;signal
function M=M_pq(X,p,q)
M=mean(X.^(p-q).*conj(X).^q);
end
