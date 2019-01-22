clc
clear all;
close all;
%use orthogonal modulation generate modulated siganl
%You can see the original signal v in the code.
fc=1e4;                                                 %carrier frequency
fs=1e5;                                                 %sample frequency
Rs=1e3;                                                 %symbol rate of digital signal
T=1/fs;                                                 %sample time
L=3000;                                                 %length of signal
t=(0:L-1)*T;                                            %time vector
A=1;                                                    %%Ampltitude
v=A*cos(2*pi*1000*t);                                   %modulation signal
xs=sin(2*pi*fc*t);
xc=cos(2*pi*fc*t);
%% Analog modulation
%FM                                                 
K_omega=0.3;                                            %freq offet index
phi_fm=zeros(1,length(v));
for n=3:length(v)
 phi_fm(n)=K_omega/(2)*(v(1)+v(n)+2*sum(v(2:n-1)));     %page 209£¬I don't
                                                        %understand this.
                                                        %pay attention:not
                                                        %use fs 
end
y_fm=cos(2*pi*fc.*t+phi_fm);

%AM
m_a=0.3;                                               %modulation index,|m_a|<1
I_AM=A+m_a*v;
Q_AM=0;
y_AM=I_AM.*xc+Q_AM.*xs;

%DSB
I_DSB=v;
Q_DSB=0;
y_DSB=I_DSB.*xc+Q_DSB.*xs;

%SSB
I_SSB=v;
Q_SSB=imag(hilbert(v));                               %LSB
%Q_SSB=-imag(hilbert(v));                             %USB
y_SSB=I_SSB.*xc+Q_SSB.*xs;

%ISB(LSB and USB have different information)
v_L=cos(2*pi*200*t);
I_ISB=v+v_L;
Q_ISB=imag(hilbert(v))-imag(hilbert(v_L));
y_ISB=I_ISB.*xc+Q_ISB.*xs;

%% digital modulation
%2ASK
%           _________          ______
%   signal |         |        |      |      
%----------|         |________|      |  so L/fs/T_ask is the length of a_n
%           <-T_ask->                       
%<-----------L points --------------->
T_ask=1/Rs;                                          
a_n=round(rand(1,round(L/(T_ask*fs))));
a_ask=repmat(a_n,T_ask*fs,1);
a_ask=a_ask(:)';
%stairs(a_ask)                                        %figure 2ask,unuse plot
I_ask=0;
Q_ask=a_ask;
y_2ask=I_ask.*xc+Q_ask.*xs;

%MASK
T_mask=1/Rs;
M=4;                                                  %M-ary
a_n=round((M-1)*rand(1,round(L/(T_mask*fs))))*(1/M);  %region 0 to 1 by 1/M.
a_mask=repmat(a_n,T_mask*fs,1);
a_mask=a_mask(:)';
%stairs(a_mask)                                       %figure mask,unuse plot
I_mask=0;
Q_mask=a_mask;
y_mask=I_mask.*xc+Q_mask.*xs;

%2FSK
fc1=2e4;                                               
xs1=sin(2*pi*fc1*t);
xc1=cos(2*pi*fc1*t);
T_fsk=1/1000;                                        
a_n=round(rand(1,round(L/(T_fsk*fs))));
a_fsk1=repmat(a_n,T_fsk*fs,1);
a_fsk1=a_fsk1(:)';
a_fsk2=a_fsk1<1;                                      %0->1,1->0
%stairs(a_fsk1)
I_fsk1=0;
Q_fsk1=a_fsk1;
I_fsk2=0;
Q_fsk2=a_fsk2;
y_fsk=I_fsk1.*xc+Q_fsk1.*xs+I_fsk2.*xc1+Q_fsk2.*xs1;  %equal to add two ask
%plot(y_fsk)

%4FSK
M=4;
fc_M=(1:M)*5e3;                                       %M groups of carrier frequency
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
y_MFSK=sum(y_MFSK,1);

%2PSK
T_psk=1/Rs;                                          
a_n=round(rand(1,round(L/(T_psk*fs))));
a_n=2*(a_n>0)-1;
a_psk=repmat(a_n,T_psk*fs,1);
a_psk=a_psk(:)';
%stairs(a_psk)                                       
I_psk=a_psk;
Q_psk=0;
y_2psk=I_psk.*xc+Q_psk.*xs;

%2DPSK :reference phase=0
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
%stairs(a_dpsk)                                       
I_dpsk=a_dpsk;
Q_dpsk=0;
y_2dpsk=I_dpsk.*xc+Q_dpsk.*xs;

%QPSK
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
I_QPSK=repmat(I_QPSK,T_dpsk*fs,1);
I_QPSK=I_QPSK(:)';
Q_QPSK=repmat(Q_QPSK,T_dpsk*fs,1);
Q_QPSK=Q_QPSK(:)';
y_qpsk=I_QPSK.*xc+Q_QPSK.*xs;

%QAM
%MSK
%GMSK
%% ModulationRecognition
%modulation_recognize(y_fm,Rs,fc,fs);
%modulation_recognize(y_AM,Rs,fc,fs);
%modulation_recognize(y_DSB,Rs,fc,fs);
%modulation_recognize(y_SSB,Rs,fc,fs);
%modulation_recognize(y_2ask,Rs,fc,fs);
%modulation_recognize(y_mask,Rs,fc,fs);
%modulation_recognize(y_fsk,Rs,fc,fs);
%modulation_recognize(y_MFSK,Rs,fc,fs);
%modulation_recognize(y_2psk,Rs,fc,fs);
%modulation_recognize(y_qpsk,Rs,fc,fs);

%% external data test
%{
% Read data from a picked file
[filename, pathname] = uigetfile('*.dat', 'Pick a data file');
fid = fopen([pathname,filename]);
data = fread(fid,'int16');
fclose(fid);

Fs = 156.25e3;%Sample rate
iqData = data(1:2:end)+1i*data(2:2:end);%IQ data
frameData = reshape(iqData,4096,[]);%Frame size is 4096

a_h=hilbert(data(1:2:end/8));   
amp_a=abs(a_h);                                        %Envelope calculation from the Hilbert transform
m_a=mean(amp_a);
subplot(1,2,1)
plot(amp_a)
subplot(1,2,2)
plot(data(1:2:end/8))
%}


