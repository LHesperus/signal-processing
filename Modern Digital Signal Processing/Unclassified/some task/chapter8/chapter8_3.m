%假设信号?1?(?)是期望信号，信号?2?(?)是干扰信号，使用MVDR 算法实现DBF。分
%别使用128、256、512 和1024 个快拍实现DBF。每种快拍数条件下，给出一次典
%型实验的方向图。
clc
clear 
close all

%% parameter
j=sqrt(-1);
M=8;       %Number of elements
K=2;        %number of source
d=0.5;      % lambda/2
theta=[-20 30]*pi/180; %DOA
kk=1;      %Signals of interest
SNR_theta=[10 30];
L=1024;              %number of snapshot

    %% gen signal
   % S=10.^(SNR_theta/20)'.*exp(j*2*pi*[0.15 0.1]'.*(0:L-1)+j*2*pi*rand(K,L));
    S=10.^(SNR_theta/20)'.*exp(j*2*pi*rand(K,L));
    A=exp(-j*(0:M-1)'.*2*pi*d*sin(theta));
    N=randn(M,L)+randn(M,L)*j;  %gauss noise
    X=A*S+N;
    
    %% MVDR
    R=X*X'/L;
    a=A(:,kk);
    wo=inv(R)*a/(a'*inv(R)*a);   
    D=10;
    theta_range=(-90:1/D:90)*pi/180;
    for tt=1:length(theta_range)
        a_d=exp(-j*2*pi*d*(0:M-1)'.*sin(theta_range(tt)));
        F_d(tt)=abs(wo'*a_d);
    end
    f_d=20*log10(F_d/max(F_d));  
    figure
    plot(theta_range/pi*180,f_d)
    title('MVDR DBF')
    xlabel('\theta  / \circ')
    ylabel('Normalized Direction Graph /dB')