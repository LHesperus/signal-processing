clc
clear 
close all

%% parameter
j=sqrt(-1);
M=8;       %Number of elements
K=2;        %number of source
d=0.5;      % lambda/2
theta=[0 30]*pi/180; %DOA
kk=1;      %Signals of interest
SNR_theta=[20 20];
L=1024;              %number of snapshot

%% 
S=10.^(SNR_theta/20)'.*exp(j*2*pi*rand(K,L));
A=exp(-j*(0:M-1)'.*2*pi*d*sin(theta));
N=randn(M,L)+randn(M,L)*j;  %gauss noise
X=A*S+N;

%% beam-space MUSIC
B=M;
m=0;
W=exp(-j*pi*(0:M-1).'.*(0:M-1)*2/M);
T=1/sqrt(M) *W(:,m+1:m+B);
Y=T'*X;

Ry_hat=Y*Y'/L;
[V,D]=eig(Ry_hat);
[aa,bb]=sort(diag(D));
G=V(:,bb(M-K:-1:M-B+1));
theta_range=(-90:0.1:90)*pi/180;
for tt=1:length(theta_range)
    a=exp(-j*2*pi*d*(0:M-1).'.*sin(theta_range(tt)));
    a=T'*a;
    P_BS_MUSIC(tt)=1/(a'*G*G'*a);
end
P_BS_MUSIC=10*log10(abs(P_BS_MUSIC));
figure
plot(theta_range/pi*180,P_BS_MUSIC);
title('P_{BS-MUSIC}')
xlabel('\theta / \circ')
ylabel('Normalized spatial spectrum /dB')