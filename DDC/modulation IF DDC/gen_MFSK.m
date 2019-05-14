%Generating FM signal
function [y_MFSK,I_mfsk,Q_mfsk]=gen_MFSK(A,fc,fs,Rs,L,M)
%use orthogonal modulation generate modulated siganl
%You can see the original signal v in the code.
if nargin==0
fc=1e4;                                                 %carrier frequency
fs=1e5;                                                 %sample frequency
Rs=2e3;                                                 %symbol rate of digital signal
L=500;                                                 %length of signal
A=1;                                                    %%Ampltitude
M=4;
end
T=1/fs;                                                 %sample time
t=(0:L-1)*T;                                            %time vector
                                              

%fc_M=(1:M)*5e3;                                       %M groups of carrier frequency
fc_M=(1:M)*fc;  
xsM=sin(2*pi*fc_M'*t);
xcM=cos(2*pi*fc_M'*t);
T_MFSK=1/Rs;
a_n=round((M-1)*rand(1,round(L/(T_MFSK*fs))))*(1/M);
a_mfsk=repmat(a_n,T_MFSK*fs,1);
a_mfsk=a_mfsk(:)';
%stairs(a_mfsk)                                       
a_mfsk_M=zeros(M,L);
for i=1:M
    a_mfsk_M(i,:)=(a_mfsk==(i-1)/M);
end
I_mfsk=0;
Q_mfsk=a_mfsk_M;
y_MFSK=I_mfsk.*xcM+Q_mfsk.*xsM;
y_MFSK=A*sum(y_MFSK,1);



