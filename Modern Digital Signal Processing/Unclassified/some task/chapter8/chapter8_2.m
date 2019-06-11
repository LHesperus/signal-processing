clc
clear all
close all

%% parameter
j=sqrt(-1);
M=16;       %Number of elements
K=2;        %number of source
d=0.5;      % lambda/2
theta=[-20 30]*pi/180; %DOA
SNR_theta=[0 0];
L=100;              %number of snapshot


%% N test
test_N=100;
for test=1:test_N
    %% gen signal
    S=10.^(SNR_theta/10)'.*exp(j*2*pi*rand(K,L));
    A=exp(-j*(0:M-1)'.*2*pi*d*sin(theta));
    N=randn(M,L)+randn(M,L)*j;  %gauss noise
    X=A*S+N;
    
    %% TLS-ESPRIT
    R=X*X'/L;
    [V,D]=eigs(R);
    [B,I] = sort(diag(D));
    G=V(:,I(end-K+1:end));
    S1=G(1:M-1,:);
    S2=G(2:M,:);
    S12=[S1 S2];
    [V,~]=eigs(S12'*S12);  % eigs ,not eig
    U12=V(1:K,K+1:end);
    U22=V(K+1:end,K+1:end);
    phi_TLS=-U12*inv(U22);
    % phi_TLS=S1\S2;   % ESPRIT
    [V,D]=eigs(phi_TLS);
    e_jphi=diag(D);
    theta_est= asin(-angle(e_jphi)/(d*2*pi))/pi*180;
    theta_est=sort(theta_est);
    err(:,test)=abs(theta_est-(theta/pi*180).');
end
MSE=mean(mean(err.^2));
