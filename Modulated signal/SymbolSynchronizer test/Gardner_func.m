function [yiq,ypc] = Gardner_func(xiq,sps)
j=sqrt(-1);
rf=0.6;
span=4;
h1 = rcosdesign(rf,span,sps,'sqrt');
xi=real(xiq);
xq=imag(xiq);
yi=conv(xi,h1);
yq=conv(xq,h1);
ypc=yi+yq*j;
%% TED
 %parameter
N=sps;
aa=0.707;
BT=0.005;
K0=-1;
alpha=0.5;
Kp=1/(4*pi*(1-alpha^2/4))*sin(pi*alpha/2);
K1=(4*aa/N*(BT/(aa+1/(4*aa))))/(1+(2*aa/N*(BT/(aa+1/(4*aa))))+(BT/(N*(aa+1/(4*aa))))^2)/Kp/K0;
K2=4*(BT/(N*(aa+1/(4*aa))))^2/(1+(2*aa/N*(BT/(aa+1/(4*aa))))+(BT/(N*(aa+1/(4*aa))))^2)/Kp/K0;

CNT_next=0;
mu_next=0;
underflow=0;
vi=0;
TEDBuffI=zeros(2,1);
TEDBuffQ=zeros(2,1);
k=1;
e_max=4*max([yi,yq]);
for n=2:length(yi)-2
    CNT=CNT_next;
    mu=mu_next;
    u(n)=mu;
    v2i=1/2*[1,-1,-1,1]*yi(n+2:-1:n-1)';
    v2q=1/2*[1,-1,-1,1]*yq(n+2:-1:n-1)';
    v1i=1/2*[-1,3,-1,-1]*yi(n+2:-1:n-1)';
    v1q=1/2*[-1,3,-1,-1]*yq(n+2:-1:n-1)';
    v0i=yi(n);
    v0q=yq(n);
    yI=(mu*v2i+v1i)*mu+v0i;
    yQ=(mu*v2q+v1q)*mu+v0q;
    if underflow==1
        e(n)=TEDBuffI(1)*(sign(TEDBuffI(2))-sign(yI))+TEDBuffQ(1)*(sign(TEDBuffQ(2))-sign(yQ));
        e(n)=e(n)/e_max;
        %e(n)=0;
        xxI(k)=yI;
        xxQ(k)=yQ;
        k=k+1;
    else 
        e(n)=0;
       % e(n)=TEDBuffI(1)*(sign(TEDBuffI(2))-sign(yI))+TEDBuffQ(1)*(sign(TEDBuffQ(2))-sign(yQ));
    end
    vp=K1*e(n);
    vi=vi+K2*e(n);
    v=vp+vi;
    vvi(n)=vi;
    %W(n)=1/N;
    W(n)=1/N+v;
    
    % update registers
    CNT_next=CNT-W(n);
    cnt_next(n)=CNT_next;
    if CNT_next<0
        CNT_next=1+CNT_next;
        underflow=1;
        mu_next=CNT/W(n);
    else
        underflow=0;
        mu_next=mu;
    end
    TEDBuffI=[yI;TEDBuffI(1)];
    TEDBuffQ=[yQ;TEDBuffQ(1)];
end
yiq=xxI+xxQ*j;
% figure;plot(xxI);title('q')
% figure;plot(vvi);title('vi')
% figure;plot(cnt_next);title('cnt_next')
% figure;plot(W);title('W')
% figure;plot(e);title('TED')
% figure;plot(u);title('\mu')

end

