clc
clear all
close all

%%parameter
j=sqrt(-1);
M=16;       %Number of elements
K=2;        %number of source
d=0.5;      % lambda/2
theta=[-20 30]*pi/180; %DOA
SNR_theta=[0 30];
L=256;              %number of snapshot


%% N test
test_N=100;
for test=1:test_N
    %% gen signal
    S=10.^(SNR_theta/10)'.*exp(j*2*pi*rand(K,L));
    A=exp(-j*(0:M-1)'.*2*pi*d*sin(theta));
    N=randn(M,L)+randn(M,L)*j;  %gauss noise
    X=A*S+N;
    
    %%
    R=X*X'/L;
    [V,D]=eig(R);
    [B,I] = sort(diag(D));
    G=V(:,I(1:end-K));
    

end
