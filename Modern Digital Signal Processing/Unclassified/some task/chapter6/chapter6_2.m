clc
clear all
close all

%% parameter
M=5;             %Equalization filter have 2M+1Tap
N=400;  %Iteration times :N-1
L_a=2;    %Channel length:L+1
SNR=20;          %v(n)

snr_i=1;
for SNR=5:5:30 
	sigma_v=1/10^(SNR/10);
	%Shock response
	h_a=[0.389 1.000 0.389];
	%h_a=[0.407 0.815 0.407];
	%h_a=[0.0472 -0.05 0.07 -0.21 -0.05 0.72 0.36 0 0.21 0.03 0.07];
	%Channel matrix (2M+1)*(2M+L+1)
	H_a=toeplitz([h_a(1) zeros(1,2*M)],[h_a, zeros(1,2*M)]);
	
	test_N=100;
	xi_test=0;
	J_a=0;
	for test=1:test_N
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
		
		%% RLS
		lambda=0.99;
		delta=0.004;
		I=diag(ones(1,2*M+1));
		P=1/delta*I;
		w_est=zeros(2*M+1,N);
		w_est(:,1)=[zeros(1,M) 1 zeros(1,M)].';
		d_a=S_a(M+1,:);     %set delay
		p_a=U_a*d_a'/N;
		for nn=1:N-1
			k=1/lambda * P *U_a(:,nn)/ ( 1+1/lambda*U_a(:,nn)'*P*U_a(:,nn));
			xi(nn)=d_a(nn)-w_est(:,nn)'*U_a(:,nn);
			w_est(:,nn+1)=w_est(:,nn)+k*conj(xi(nn));
			P=1/lambda*P-1/lambda*k*U_a(:,nn)'*P;
			J_min_a(nn+1)=mean(S_a(:,nn+1).^2)-p_a'*w_est(:,nn+1);
		end
		xi_test=xi_test+abs(xi);
		J_a=J_a+J_min_a;
	end   
	xi_test=xi_test/test_N;
	J_a=J_a/test_N;
	
	xi_SNR(snr_i,:)=abs(xi_test).^2;
	xi_min_SNR(snr_i)=xi_test(end-1);
	snr_i=snr_i+1;
	%figure
	%semilogy(aaa)
	%figure
	%semilogy(abs(J_a))
end
figure
semilogy(xi_test.^2);
figure
plot((5:5:30),xi_min_SNR);
xlabel('SNR/dB');ylabel('MSE');title('RLS Steady state simulation')

figure
semilogy(xi_SNR(1,:),'r');hold on;
semilogy(xi_SNR(2,:),'b');hold on;
semilogy(xi_SNR(3,:),'g');hold on;
semilogy(xi_SNR(4,:),'y');hold on;
semilogy(xi_SNR(5,:),'c');hold on;
semilogy(xi_SNR(6,:),'m');
xlabel('Iteration times');ylabel('MSE');title('RLS transient simulation')
legend('5dB', '10dB', '15dB' ,'20dB' ,'25dB' ,'30dB')