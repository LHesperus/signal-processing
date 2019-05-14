%Generating FM signal
function [y_fsk,I_FSK,Q_FSK]=gen_FSK2(A,fc,fs,Rs,L)
%use orthogonal modulation generate modulated siganl
%You can see the original signal v in the code.
if nargin==0
fc=1e4;                                                 %carrier frequency
fs=1e5;                                                 %sample frequency
Rs=5e3;                                                 %symbol rate of digital signal
L=1000;                                                 %length of signal
fc1=1.1e4;                                              %|fc1-fc|<Rs
fc1=3e4;                                                %|fc1-fc|>Rs
A=1;                                                    %%Ampltitude
end
T=1/fs;                                                 %sample time
t=(0:L-1)*T;                                            %time vector
xs=sin(2*pi*fc*t);
xc=cos(2*pi*fc*t);


xs1=sin(2*pi*fc1*t);
xc1=cos(2*pi*fc1*t);
T_fsk=1/Rs;                                        
a_n=round(rand(1,round(L/(T_fsk*fs))));
a_fsk1=repmat(a_n,T_fsk*fs,1);
a_fsk1=a_fsk1(:)';
a_fsk2=a_fsk1<1;                                      %0->1,1->0


I_fsk1=0;
Q_fsk1=a_fsk1;
I_fsk2=0;
Q_fsk2=a_fsk2;
y_fsk=I_fsk1.*xc+Q_fsk1.*xs+I_fsk2.*xc1+Q_fsk2.*xs1;  %equal to add two ask
y_fsk=A*y_fsk;
I_FSK=[I_fsk1;I_fsk2];
Q_FSK=[Q_fsk1;Q_fsk2];


