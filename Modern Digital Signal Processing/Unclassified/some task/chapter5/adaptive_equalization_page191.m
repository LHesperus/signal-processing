clc
clear all
close all
%% Parameter
M=5;      %Equalization filter have 2M+1Tap
L_a=2;    %Channel length:L+1
L_b=2;
L_c=10;
N=100000;  %Iteration times :N-1
SNR=30;   %v(n)
sigma_v=1/10^(SNR/10);
v=sqrt(sigma_v)*randn(2*M+N,1);  %noise
%Shock response
h_a=[0.389 1.000 0.389];
h_b=[0.407 0.815 0.407];
h_c=[0.0472 -0.05 0.07 -0.21 -0.05 0.72 0.36 0 0.21 0.03 0.07];
%Channel matrix (2M+1)*(2M+L+1)
H_a=toeplitz([h_a(1) zeros(1,2*M)],[h_a, zeros(1,2*M)]);
H_b=toeplitz([h_b(1) zeros(1,2*M)],[h_b, zeros(1,2*M)]);
H_c=toeplitz([h_c(1) zeros(1,2*M)],[h_c, zeros(1,2*M)]);
% Bernoulli Sequence :training sequence;-1¡¢1 mean=0;Average power=1
sa_ts=randsrc(2*M+L_a+N,1);      
sb_ts=randsrc(2*M+L_b+N,1);
sc_ts=randsrc(2*M+L_c+N,1);
%Observation data matrix
S_a=zeros(2*M+L_a+1,N);
S_b=zeros(2*M+L_b+1,N);
S_c=zeros(2*M+L_c+1,N);
%noise matrix
V_a=zeros(2*M+1,N);
V_b=zeros(2*M+1,N);
V_c=zeros(2*M+1,N);
for nn=1:N
    S_a(:,nn)=sa_ts(2*M+L_a+nn:-1:nn);
    S_b(:,nn)=sb_ts(2*M+L_b+nn:-1:nn);
    S_c(:,nn)=sc_ts(2*M+L_c+nn:-1:nn);
    V_a(:,nn)=v(2*M+nn:-1:nn);
    V_b(:,nn)=v(2*M+nn:-1:nn);
    V_c(:,nn)=v(2*M+nn:-1:nn);
end
% input of equalizer
U_a=H_a*S_a+V_a;   
U_b=H_b*S_b+V_b;
U_c=H_c*S_c+V_c;

%% LMS
mu=0.01;  %step
err=zeros(N,1);
w=zeros(2*M+1,N);
d_est=zeros(1,N);
J_min=zeros(1,N);
w(M+1,1)=1;       %Initialization weight,Intermediate value=1
R_a=U_a*U_a'/(N);
d=S_a(M+1,:);     %set delay
p_a=U_a*d'/N;
d_est(1)=w(:,1)'*U_a(:,1);
err(1)=d(1)-d_est(1);
J_min(1)=mean(S_a(:,1).^2)-p_a'*w(:,1);
for nn=1:N-1
   w(:,nn+1)=w(:,nn)+mu*U_a(:,nn)*err(nn);
   d_est(nn+1)=w(:,nn+1)'*U_a(:,nn+1);
   err(nn+1)=d(nn+1)-d_est(nn+1);
   J_min(nn+1)=mean(S_a(:,nn+1).^2)-p_a'*w(:,nn+1);
end

%% result
%Eigenvalue Extension
[~,lambda_a]=eig(R_a);
chi_a=max(diag(lambda_a))/min(diag(lambda_a));

figure
stem(w(:,end))
figure
err=err.^2;
plot(err)
figure
plot(J_min)