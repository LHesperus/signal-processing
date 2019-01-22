%归一化零中心瞬时幅度绝对值的方差，page 262,(5-288)
%You can use this function to distinguish signal likes 2ASK and 4ASK. But the
%output is very close. Usually take 0.25 as threshold.
function y=sigma_aa(a)
a_h=hilbert(a);   
amp_a=abs(a_h);                                        %Envelope calculation from the Hilbert transform
m_a=mean(amp_a);
a_n=amp_a/m_a;
a_cn=a_n-1;
%plot(a_cn)
sigma_aa=sqrt(mean(a_cn.^2)-mean(abs(a_cn)).^2);
y=sigma_aa;
end