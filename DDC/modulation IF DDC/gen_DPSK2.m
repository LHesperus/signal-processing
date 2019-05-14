%Generating 2DPSK signal
function [y_2dpsk,I_dpsk,Q_dpsk]=gen_DPSK2(A,fc,fs,Rs,L)
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

T_dpsk=1/Rs;                                          
a_n=round(rand(1,round(L/(T_dpsk*fs))));
%2psk to 2dpsk
for i=2:length(a_n)
    if a_n(i)==1
        a_n(i)=abs(a_n(i-1)-1);                          %if a_n=1 then 0->1,1->0
    else
        a_n(i)=a_n(i-1);
    end
end
a_n=2*(a_n>0)-1;                                         %turn 0 of a_n to -1
a_dpsk=repmat(a_n,T_dpsk*fs,1);
a_dpsk=a_dpsk(:)';                                  
I_dpsk=a_dpsk;
Q_dpsk=0;
y_2dpsk=A*(I_dpsk.*xc+Q_dpsk.*xs);
