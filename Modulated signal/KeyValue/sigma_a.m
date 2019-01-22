%非弱信号段零中心归一化瞬时幅度的方差,page 264,(5-290)
% a:modulated signal
%a_t:threshold
%you can use "%plot" to observed data,and you will find that a_cn of DSB
%and AM has dynamic ampltitude,and a_cn of PSK has invariant amplitude.So
%the code maybe effective,but sigma_a can't obviously distinguish different data
function y=sigma_a(a,a_t)
a_h=hilbert(a);   
amp_a=abs(a_h);                                        %Envelope calculation from the Hilbert transform
m_a=mean(amp_a);
%plot(amp_a)
a_n=amp_a/m_a;
a_cn=a_n-1;
%plot(a_cn)
a_cn=a_cn(a_cn>a_t);                                   %equal to a_cn=a_cn(find(a_cn>a_t))
if size(a_cn,2)==0
    a_cn=0;
end
%plot(a_cn)
sigma_a=sqrt(mean(a_cn.^2)-mean(a_cn).^2);
y=sigma_a;
end