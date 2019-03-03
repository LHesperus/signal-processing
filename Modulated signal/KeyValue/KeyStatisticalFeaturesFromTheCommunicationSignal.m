%
clc
clear


%% Hilbert transformation  
%MSK;      a=s;                                     %s:MSK signal
GMSK;     a=s;
%OQPSK;    a=OQPSK_signal;
%pi4DQPSK;  a=pi4DQPSK_signal;
%QAM;      a=MQAM;
a_h=hilbert(a);
amp_a=abs(a_h);                                        %Envelope calculation from the Hilbert transform
m_a=mean(amp_a);

%% plot envelope
figure
plot(amp_a)
title('signal envelope:A_{n}')
a_n=amp_a/m_a;
a_cn=a_n-1;
figure
plot(a_cn)
title('signal envelope:A_{cn}')


%% plot phi
angle_a=angle(a_h);
angle_a=unwrap(angle_a);
for i=1:length(angle_a)
  angle_a(i)=mod(angle_a(i)-2*pi*fc*i/fs,2*pi);          %(5-295)
end
figure
angle_a=wrapToPi(angle_a);
plot(angle_a)
title('phase of signal \Phi(i)\in[-\pi,\pi]')
angle_a=angle_a-mean(angle_a);
figure%may be have problems
plot(angle_a)
title('\Phi_{NL}')
figure
plot(abs(angle_a))
title('|\Phi_{NL}|')


%% 
gamma=MaxSpectralDensity(a)

%% 
%a=a_h;%%error 
%a=s;%QAM
%a=s_complex;%OQPSK,pi/4DQPSK
C21=M_pq(a,2,1)
C40=M_pq(a,4,0)-3*M_pq(a,2,0)^2;
C42=M_pq(a,4,2)-M_pq(a,2,0).^2-2*M_pq(a,2,1).^2;
C63=M_pq(a,6,3)-6*M_pq(a,4,1).*M_pq(a,2,0)-9*M_pq(a,4,2).*M_pq(a,2,1)+18*M_pq(a,2,0).^2.*M_pq(a,2,1)+12*M_pq(a,2,1).^3;
C80=M_pq(a,8,0)-28*M_pq(a,2,0).*M_pq(a,6,0)-35*M_pq(a,4,0).^2+420*M_pq(a,2,0).^2.*M_pq(a,4,0)-630*M_pq(a,2,0).^4;
[C21 C40 C42 C63 C80]
C_f=abs(C80)/abs(C42)^2

