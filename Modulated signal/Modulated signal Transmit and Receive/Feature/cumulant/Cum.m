%a :»ù´øÐÅºÅ
function y=Cum(a,type)
C21=M_pq(a,2,1);
C40=M_pq(a,4,0)-3*M_pq(a,2,0)^2;
C42=M_pq(a,4,2)-M_pq(a,2,0).^2-2*M_pq(a,2,1).^2;
C63=M_pq(a,6,3)-6*M_pq(a,4,1)*M_pq(a,2,0)-9*M_pq(a,4,2)*M_pq(a,2,1)+18*M_pq(a,2,0)^2*M_pq(a,2,1)+12*M_pq(a,2,1)^3;
C80=M_pq(a,8,0)-28*M_pq(a,2,0).*M_pq(a,6,0)-35*M_pq(a,4,0).^2+420*M_pq(a,2,0).^2.*M_pq(a,4,0)-630*M_pq(a,2,0).^4;
switch type
    case 0
        y=abs(C80)/abs(C42)^2;
    case 21
        y=real(C21);
    case 40
        y=real(C40);
    case 42
        y=real(C42);
    case 63
        y=real(C63);
    case 80
        y=real(C80);
    otherwise
        disp('error');
end

end
%X;signal
function M=M_pq(X,p,q)
M=mean(X.^(p-q).*conj(X).^q);
end
