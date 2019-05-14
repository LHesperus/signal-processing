%Generating FM signal
function [y_fm,I_FM,Q_FM]=gen_FM(A,fc,fs,L)
%use orthogonal modulation generate modulated siganl
%You can see the original signal v in the code.
if nargin==0
fc=1e4;                                                 %carrier frequency
fs=1e5;                                                 %sample frequency
L=500;                                                 %length of signal
A=1;                                                    %%Ampltitude
end
T=1/fs;                                                 %sample time
t=(0:L-1)*T;                                            %time vector

v=A*cos(2*pi*1000*t);                                   %modulation signal

%FM                                                 
K_omega=0.5;                                            %freq offet index
phi_fm=zeros(1,length(v));
for n=3:length(v)
 phi_fm(n)=K_omega/(2)*(v(1)+v(n)+2*sum(v(2:n-1)));     
end
y_fm=A*cos(2*pi*fc.*t+phi_fm);
I_FM=cos(phi_fm);
Q_FM=-sin(phi_fm);

