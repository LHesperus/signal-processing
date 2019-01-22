%归一化零中心瞬时幅度之谱密度的最大值，page 260，（5-284）
function y=MaxSpectralDensity(a)
Ns=length(a);
a_h=hilbert(a);
amp_a=sqrt(real(a_h).*real(a_h)+imag(a_h).*imag(a_h));    %Envelope calculation from the Hilbert transform
m_a=mean(amp_a);
a_n=amp_a/m_a;
a_cn=a_n-1;
gamma_max=max(abs(fft(a_cn)))*max(abs(fft(a_cn)))/Ns;
y=gamma_max;
end