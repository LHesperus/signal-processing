%零中心归一化瞬时频率的四阶矩 page 264,(5-292)
%测试点（plot）的波形应该是正确的，但输出结果不能区分信号，也许只能区分4fsk和fm信号
function y=mu_f_42(a,fs,Rs)
%Rs=1000;                                                %symbol rate,if possible, it is best to estimate it.
N=length(a);
a_h=hilbert(a);
angle_a=angle(a_h);
angle_a=unwrap(angle_a);
%for i=1:length(angle_a)
%  angle_a(i)=mod(angle_a(i)-2*pi*fc*i/fs,2*pi);          %(5-295)
%end
phi_NL=angle_a-mean(angle_a);
f=fs/2/pi*(phi_NL(2:N)-phi_NL(1:N-1));
%plot(f)
m_f=mean(f);
f_m=f-m_f;
f_N=f_m/Rs;
%plot(f_N)
%在此处做过非弱信号段方式的测试，输出结果无明显变化
mu_f_42=mean(f_N.^4)/(mean(f_N.^2)^2);
y=mu_f_42;
end