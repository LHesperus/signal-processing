clc
clear all
close all

%% parameter
M=2;
L=2000;
b=1;
a=[1 -0.975 0.95];
w_theory=-conj(a(2:end)).';
sigma_v_2=0.0731;
test_N=100;
x_test=0;
err_test=0;
for test=1:test_N
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
	alpha(nn)=z(nn)-C*x_est(:,nn);
	x_est(:,nn+1)=x_est(:,nn)+K*alpha(nn);
	P=(eye(M)-K*C)*P;
    
    end
    err=abs(x_est-w_theory);
    %err=abs(alpha);
	x_test=x_test+x_est;
    err_test=err_test+err;
end	
x_test=x_test/test_N;
err_test=err_test/test_N;
err_test=err_test.^2;
x_test(:,end)
figure
plot(x_test(1,:))
hold on
plot(x_test(2,:))
ylabel('Weight')
xlabel('Iteration times')
legend('w1', 'w2')
title('Kalman learning curve')

figure
semilogy(err_test(1,:))
hold on
semilogy(err_test(2,:))
ylabel('MSE')
xlabel('Iteration times')
legend('w1', 'w2')
title('Kalman learning curve')
