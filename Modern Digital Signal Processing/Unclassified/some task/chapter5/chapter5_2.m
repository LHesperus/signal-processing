clc
clear all
close all
%% Parameter
M=16;      %Equalization filter have 2M+1Tap
L_a=2;    %Channel length:L+1
L_b=2;
L_c=10;
N=40000;  %Iteration times :N-1
SNR=20;   %v(n)
sigma_v=1/10^(SNR/10);
%Shock response
h_a=[0.389 1.000 0.389];
h_b=[0.407 0.815 0.407];
h_c=[0.0472 -0.05 0.07 -0.21 -0.05 0.72 0.36 0 0.21 0.03 0.07];
%Channel matrix (2M+1)*(2M+L+1)
H_a=toeplitz([h_a(1) zeros(1,2*M)],[h_a, zeros(1,2*M)]);
H_b=toeplitz([h_b(1) zeros(1,2*M)],[h_b, zeros(1,2*M)]);
H_c=toeplitz([h_c(1) zeros(1,2*M)],[h_c, zeros(1,2*M)]);

for ii=1:100
    v=sqrt(sigma_v)*randn(2*M+N,1);  %noise
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
    mu_a=0.01;  %step
    mu_b=0.01;  %step
    mu_c=0.01;  %step
    err_a=zeros(N,1);
    err_b=zeros(N,1);
    err_c=zeros(N,1);
    w_a=zeros(2*M+1,N);
    w_b=zeros(2*M+1,N);
    w_c=zeros(2*M+1,N);
    d_est_a=zeros(1,N);
    d_est_b=zeros(1,N);
    d_est_c=zeros(1,N);
    J_min_a=zeros(1,N);
    J_min_b=zeros(1,N);
    J_min_c=zeros(1,N);
    w_a(M+1,1)=1;       %Initialization weight,Intermediate value=1
    w_b(M+1,1)=1;
    w_c(M+1,1)=1;
    R_a=U_a*U_a'/(N);
    R_b=U_b*U_b'/(N);
    R_c=U_c*U_c'/(N);
    d_a=S_a(M+1,:);     %set delay
    d_b=S_b(M+1,:);
    d_c=S_c(M+1,:);
    p_a=U_a*d_a'/N;
    p_b=U_b*d_b'/N;
    p_c=U_c*d_c'/N;
    d_est_a(1)=w_a(:,1)'*U_a(:,1);
    d_est_b(1)=w_b(:,1)'*U_b(:,1);
    d_est_c(1)=w_c(:,1)'*U_c(:,1);
    err_a(1)=d_a(1)-d_est_a(1);
    err_b(1)=d_b(1)-d_est_b(1);
    err_c(1)=d_c(1)-d_est_c(1);
    J_min_a(1)=mean(S_a(:,1).^2)-p_a'*w_a(:,1);
    J_min_b(1)=mean(S_b(:,1).^2)-p_b'*w_b(:,1);
    J_min_c(1)=mean(S_c(:,1).^2)-p_c'*w_c(:,1);
    for nn=1:N-1
        % a
        w_a(:,nn+1)=w_a(:,nn)+mu_a*U_a(:,nn)*err_a(nn);
        d_est_a(nn+1)=w_a(:,nn+1)'*U_a(:,nn+1);
        err_a(nn+1)=d_a(nn+1)-d_est_a(nn+1);
      %  J_min_a(nn+1)=mean(S_a(:,nn+1).^2)-w_a(:,nn+1)'*R_a*w_a(:,nn+1);
        J_min_a(nn+1)=mean(S_a(:,nn+1).^2)-p_a'*w_a(:,nn+1);
        % b
        w_b(:,nn+1)=w_b(:,nn)+mu_b*U_b(:,nn)*err_b(nn);
        d_est_b(nn+1)=w_b(:,nn+1)'*U_b(:,nn+1);
        err_b(nn+1)=d_b(nn+1)-d_est_b(nn+1);
        J_min_b(nn+1)=mean(S_b(:,nn+1).^2)-p_b'*w_b(:,nn+1);
       
        % c
        w_c(:,nn+1)=w_c(:,nn)+mu_c*U_c(:,nn)*err_c(nn);
        d_est_c(nn+1)=w_c(:,nn+1)'*U_c(:,nn+1);
        err_c(nn+1)=d_c(nn+1)-d_est_c(nn+1);
        J_min_c(nn+1)=mean(S_c(:,nn+1).^2)-p_c'*w_c(:,nn+1);
    end
    w_end_a(ii,:)=w_a(:,end);
    w_end_b(ii,:)=w_b(:,end);
    w_end_c(ii,:)=w_c(:,end);
    J_a(ii,:)=J_min_a;
    J_b(ii,:)=J_min_b;
    J_c(ii,:)=J_min_c;
    e_a(ii,:)=err_a.^2;
    e_b(ii,:)=err_b.^2;
    e_c(ii,:)=err_c.^2;
end

%% result
%Eigenvalue Extension
[~,lambda_a]=eig(R_a);
[~,lambda_b]=eig(R_b);
[~,lambda_c]=eig(R_c);
chi_a=max(diag(lambda_a))/min(diag(lambda_a));
chi_b=max(diag(lambda_b))/min(diag(lambda_b));
chi_c=max(diag(lambda_c))/min(diag(lambda_c));

figure
w_end_a=mean(w_end_a);
w_end_b=mean(w_end_b);
w_end_c=mean(w_end_c);
stem(w_end_a);title('Optimal Weight Vector of channel a')
figure
stem(w_end_b);title('Optimal Weight Vector of channel b')
figure
stem(w_end_c);title('Optimal Weight Vector of channel c')

figure
e_a=mean(e_a);
e_b=mean(e_b);
e_c=mean(e_c);
semilogy(e_a);xlabel('Iteration times');ylabel('MSE');title('learning curve of a')
figure
semilogy(e_b);xlabel('Iteration times');ylabel('MSE');title('learning curve of b')
figure
semilogy(e_c);xlabel('Iteration times');ylabel('MSE');title('learning curve of c');

figure
J_a=mean(J_a);
J_b=mean(J_b);
J_c=mean(J_c);
semilogy(J_a);xlabel('Iteration times');ylabel('J_{min}');title('learning curve of a')
figure
semilogy(J_b);xlabel('Iteration times');ylabel('J_{min}');title('learning curve of b')
figure
semilogy(J_c);xlabel('Iteration times');ylabel('J_{min}');title('learning curve of c')