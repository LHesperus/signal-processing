% pi/4DQPSK
function [pi4DQPSK,s_complex,s,t,f]=gen_pi4DQPSK(A,fc,fs,Rs,N)
if nargin==0
    A=1;                                            %amplitude
    Rs=10e2;                                        %bit ratio
    N=1000;                                         %Number of bits to process
    fc=10e3;                                        %carrier frequency
    fs=10e4;                                        %sample frequency
end

Ts=1/Rs;
T=1/fs;
t=(0:(round(N*Ts/T)-1))*T;
L=length(t);
f=(-L/2:L/2-1)*(fs/L); 
r=round(Ts/T);

a=rand(1,N)>0.5;                               %bit symbol

%% serial-to-paralle
Idata=a(1:2:end);
Idata=repmat(Idata,2,1);
Idata=Idata(:)';

Qdata=a(2:2:end);
Qdata=repmat(Qdata,2,1);
Qdata=Qdata(:)';

%% Qdata delay one bit
Qdata=[0,Qdata(1:end-1)];

%% Gray coded
% 00->0->  pi/4
% 01->1-> 3pi/4
% 10->2-> -pi/4
% 11->3->-3pi/4
two_bits_decimal = [2,1]*[Qdata;Idata];
phase_code=pi*[1/4,3/4,-1/4,-3/4];
phi=phase_code(two_bits_decimal+1);
phi=cumsum(phi);
%From here only the phase jump of pi/4 and 3pi/4 can be seen.

phi_sample=repmat(phi,r,1);
phi_sample=phi_sample(:)';
%% constellation
j=sqrt(-1);
s=cos(phi)+sin(phi)*j;
%aaa=sum((cos(phi)>=-0.1)&(cos(phi)<=0.1))+sum((cos(phi)>=-1.1)&(cos(phi)<=-0.9))+sum((cos(phi)>=0.9)&(cos(phi)<=1.1))

%% carrier wave
xc=cos(2*pi*fc*t);
xs=sin(2*pi*fc*t);

%% pi4DQPSK
pi4DQPSK=A*(cos(phi_sample).*xc-sin(phi_sample).*xs);
s_complex=cos(phi_sample)+sin(phi_sample)*j;
s_complex=A*s_complex;
end
