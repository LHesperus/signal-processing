%Generating 2psk signal
function [y_2psk,I_psk,Q_psk]=gen_PSK2(A,fc,fs,Rs,L)
%use orthogonal modulation generate modulated siganl
%You can see the original signal v in the code.
if nargin==0
fc=5e3;                                                 %carrier frequency
fs=1e5;                                                 %sample frequency
Rs=1e3;                                                 %symbol rate of digital signal
L=1000;                                                  %length of signal
A=1;                                                    %%Ampltitude
end
T=1/fs;                                                 %sample time
t=(0:L-1)*T;                                            %time vector


xs=sin(2*pi*fc*t);
xc=cos(2*pi*fc*t);

T_psk=1/Rs;                                          
a_n=round(rand(1,round(L/(T_psk*fs))));
a_n=2*(a_n>0)-1;
a_psk=repmat(a_n,T_psk*fs,1);
a_psk=a_psk(:)';
                                 
I_psk=a_psk;
Q_psk=0;
y_2psk=A*(I_psk.*xc+Q_psk.*xs);
figure(1)
plot(y_2psk)
