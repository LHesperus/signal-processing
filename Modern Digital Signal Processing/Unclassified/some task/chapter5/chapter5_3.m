clc
clear all
close all
%% Parameter
M=5;      %Equalization filter have 2M+1Tap
L_a=2;    %Channel length:L+1
N=30000;  %Iteration times :N-1
%Shock response
h_a=[0.389 1.000 0.389];
%Channel matrix (2M+1)*(2M+L+1)
H_a=toeplitz([h_a(1) zeros(1,2*M)],[h_a, zeros(1,2*M)]);
snr_i=1;
for SNR=5:5:30
    sigma_v=1/10^(SNR/10);
    for ii=1:100
        v=sqrt(sigma_v)*randn(2*M+N,1);  %noise
        % Bernoulli Sequence :training sequence;-1¡¢1 mean=0;Average power=1
        sa_ts=randsrc(2*M+L_a+N,1);
        %Observation data matrix
        S_a=zeros(2*M+L_a+1,N);
        %noise matrix
        V_a=zeros(2*M+1,N);
        for nn=1:N
            S_a(:,nn)=sa_ts(2*M+L_a+nn:-1:nn);
            V_a(:,nn)=v(2*M+nn:-1:nn);
        end
        % input of equalizer
        U_a=H_a*S_a+V_a;     
        %% LMS
        mu_a=0.01;  %step
        err_a=zeros(N,1);
        w_a=zeros(2*M+1,N);
        d_est_a=zeros(1,N);
        J_min_a=zeros(1,N);
        R_a=U_a*U_a'/(N);
        w_a(M+1,1)=1;       %Initialization weight,Intermediate value=1
        d_a=S_a(M+1,:);     %set delay
        d_est_a(1)=w_a(:,1)'*U_a(:,1);
        err_a(1)=d_a(1)-d_est_a(1);
        p=U_a*d_a'/N;
        J_min_a(1)=mean(S_a(:,1).^2)-p'*w_a(:,1);

        for nn=1:N-1
            % a
            w_a(:,nn+1)=w_a(:,nn)+mu_a*U_a(:,nn)* err_a(nn);
            d_est_a(nn+1)=w_a(:,nn+1)'*U_a(:,nn+1);
            err_a(nn+1)=d_a(nn+1)-d_est_a(nn+1);
            J_min_a(nn+1)=mean(S_a(:,nn+1).^2)-p'*w_a(:,nn+1);
        end
        w_end_a(ii,:)=w_a(:,end);
        J_a(ii,:)=J_min_a;
        e_a(ii,:)=err_a.^2;
    end
    J_min_SNR(snr_i)=mean(J_a(end,:));
    J_snr(snr_i,:)=mean(J_a);
    snr_i=snr_i+1;
end
%% result
%Eigenvalue Extension
[~,lambda_a]=eig(R_a);
chi_a=max(diag(lambda_a))/min(diag(lambda_a));

figure
plot((5:5:30),J_min_SNR);
xlabel('SNR/dB');ylabel('J_{min}');title('Steady state simulation')

figure
semilogy(J_snr(1,:),'r');hold on;
semilogy(J_snr(2,:),'b');hold on;
semilogy(J_snr(3,:),'g');hold on;
semilogy(J_snr(4,:),'y');hold on;
semilogy(J_snr(5,:),'c');hold on;
semilogy(J_snr(6,:),'m');
xlabel('Iteration times');ylabel('J_{min}');title('transient simulation')
legend('5dB', '10dB', '15dB' ,'20dB' ,'25dB' ,'30dB')