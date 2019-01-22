%
clc
clear


%% Hilbert transformation  
%MSK;      a_h=hilbert(s);                                     %s:MSK signal
%OQPSK;    a_h=hilbert(OQPSK_signal);
pi4DQPSK; a_h=hilbert(pi4DQPSK_signal);
%QAM;      a_h=hilbert(QAM_signal);
amp_a=abs(a_h);                                        %Envelope calculation from the Hilbert transform
m_a=mean(amp_a);

%% plot envelope
figure
plot(amp_a)
title('signal envelope')
a_n=amp_a/m_a;
a_cn=a_n-1;
%figure
%plot(a_cn)


%% plot phi
angle_a=angle(a_h);
angle_a=unwrap(angle_a);
for i=1:length(angle_a)
  angle_a(i)=mod(angle_a(i)-2*pi*fc*i/fs,2*pi);          %(5-295)
end
figure
plot(wrapToPi(angle_a))
title('phase of signal [-\pi,\pi]')
angle_a=angle_a-mean(angle_a);
figure%may be have problems
plot(angle_a)
figure
plot(abs(angle_a))

%% 




