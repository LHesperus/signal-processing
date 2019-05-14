%Generating QPSK signal
function [y_qpsk,I_QPSK,Q_QPSK]=gen_QPSK(A,fc,fs,Rs,L)
%use orthogonal modulation generate modulated siganl
%You can see the original signal v in the code.
if nargin==0
fc=1e4;                                                 %carrier frequency
fs=1e5;                                                 %sample frequency
Rs=2e3;                                                 %symbol rate of digital signal
L=500;                                                 %length of signal

A=1;                                                    %%Ampltitude
end
T=1/fs;                                                 %sample time
t=(0:L-1)*T;                                            %time vector
xs=sin(2*pi*fc*t);
xc=cos(2*pi*fc*t);

T_qpsk=1/Rs;                                          
a_2n=round(rand(1,2*round(L/(T_qpsk*fs))));
phi_qpsk=[0 pi/2 pi 3*pi/2];
qpsk_code=[0,0;0,1;1,1;1,0];
I_QPSK=zeros(1,length(a_2n)/2);
Q_QPSK=zeros(1,length(a_2n)/2);
for i=1:length(a_2n)/2
    if a_2n(2*i-1:2*i)==qpsk_code(1,:)
        I_QPSK(i)=cos(phi_qpsk(1));
        Q_QPSK(i)=-sin(phi_qpsk(1));
    elseif a_2n(2*i-1:2*i)==qpsk_code(2,:)
        I_QPSK(i)=cos(phi_qpsk(2));
        Q_QPSK(i)=-sin(phi_qpsk(2));
    elseif a_2n(2*i-1:2*i)==qpsk_code(3,:)
        I_QPSK(i)=cos(phi_qpsk(3));
        Q_QPSK(i)=-sin(phi_qpsk(3));
    else
        I_QPSK(i)=cos(phi_qpsk(4));
        Q_QPSK(i)=-sin(phi_qpsk(4));
    end
end
I_QPSK=repmat(I_QPSK,T_qpsk*fs,1);
I_QPSK=I_QPSK(:)';
Q_QPSK=repmat(Q_QPSK,T_qpsk*fs,1);
Q_QPSK=Q_QPSK(:)';
y_qpsk=A*(I_QPSK.*xc+Q_QPSK.*xs);


