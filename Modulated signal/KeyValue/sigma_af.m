%非弱信号段零中心归一化瞬时频率绝对值的方差,page 263,(5-289)
function y=sigma_af(a,a_t,fs,Rs)
%Rs=1000;                                                %symbol rate,if possible, it is best to estimate it.
N=length(a);
a_h=hilbert(a);
amp_a=abs(a_h);                                         %Envelope calculation from the Hilbert transform
m_a=mean(amp_a);
a_n=amp_a/m_a;

angle_a=angle(a_h);
angle_a=unwrap(angle_a);
phi_NL=angle_a-mean(angle_a);
f=fs/2/pi*(phi_NL(2:N)-phi_NL(1:N-1));
%plot(f)
m_f=mean(f);
f_m=f-m_f;
f_N=f_m/Rs;
%plot(f_N)
a_n=a_n(1:end-1);
f_N=f_N(a_n>a_t);
%plot(f_N)
sigma_af=sqrt(mean(f_N.^2)-mean(abs(f_N))^2);
y=sigma_af;
end