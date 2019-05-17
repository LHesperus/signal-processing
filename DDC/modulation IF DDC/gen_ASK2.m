%Generating 2ASK signal
function [y_2ask,I_ask,Q_ask]=gen_ASK2(A,fc,fs,Rs,L)
%use orthogonal modulation generate modulated siganl
%You can see the original signal v in the code.
if nargin==0
    A=1;                                                    %%Ampltitude
    fc=1e4;                                                 %carrier frequency
    fs=1e5;                                                 %sample frequency
    Rs=1e3;                                                 %symbol rate of digital signal
    L=10000;                                                %length of signal
end
T=1/fs;                                                     %sample time
t=(0:L-1)*T;                                                %time vector
xs=sin(2*pi*fc*t);
xc=cos(2*pi*fc*t);

%2ASK
%           _________          ______
%   signal |         |        |      |      
%----------|         |________|      |  so L/fs/T_ask is the length of a_n
%           <-T_ask->                       
%<-----------L points --------------->
T_ask=1/Rs;                                          
a_n=round(rand(1,round(L/(T_ask*fs))));
a_ask=repmat(a_n,round(T_ask*fs),1);
a_ask=a_ask(:)';
size(xc)
size(a_ask)
%stairs(a_ask)                                        %figure 2ask,unuse plot
I_ask=0;
Q_ask=a_ask;
y_2ask=I_ask.*xc+Q_ask.*xs;
y_2ask=A*y_2ask;
end



