%a :»ù´øÐÅºÅ
function Cf=C_f(a)
C42=M_pq(a,4,2)-M_pq(a,2,0).^2-2*M_pq(a,2,1).^2;
C80=M_pq(a,8,0)-28*M_pq(a,2,0).*M_pq(a,6,0)-35*M_pq(a,4,0).^2+420*M_pq(a,2,0).^2.*M_pq(a,4,0)-630*M_pq(a,2,0).^4;
Cf=abs(C80)/abs(C42)^2;
end

%X;signal
function M=M_pq(X,p,q)
M=mean(X.^(p-q).*conj(X).^q);
end
