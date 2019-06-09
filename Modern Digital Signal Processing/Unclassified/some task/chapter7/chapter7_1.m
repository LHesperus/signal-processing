clc
clear all
close all

%% parameter
M=2;
L=100;
b=1;
a=[1 -0.975 0.95];
sigma_v_2=0.0731;

v=randn(1,L);
z=filtic(b,a,[0 0]);
u=filter(b,a,v,z);

J_min=0.005;

%%
u1=[zeros(1,M-1) u];
U=zeros(M,L);
for nn=1:L
    U(:,nn)=u1(M-1+nn:-1:nn);
end
w=zeros(1,M).';

%% kalman
Q_2=J_min;
P=eye(M);
x_est=zeros(M,L);
z=u(2:end);
for nn=1:L-1
  C=U(:,nn).';    
  A=C*P*C'+Q_2;
  K=P*C'*inv(A);
  alpha=z(nn)-C*x_est(:,nn);
  x_est(:,nn+1)=x_est(:,nn)+K*alpha;
  P=(eye(M)-K*C)*P;
end


figure
plot(x_est(1,:))
hold on
plot(x_est(2,:))
