clc
clear all
close all
j=sqrt(-1);

L=200   ;               %signal length
sigma_v_2=0.0731;      %noise power

test_N=100;
w_test=0;
xi_test=0;
for test=1:test_N
	v=sqrt(sigma_v_2)*randn(1,L);
	b=1;
	a=[1 -0.975 0.95];
    w_theory=-conj(a(2:end)).';
    %a=[1 0.99];
	z=filtic(b,a,[0 0]);
	u=filter(b,a,v,z);
    
    %%
    n0=1;               %n0 Step Linear Prediction
    M=2;
    d=u(n0+1:end);        %Expectations correspond
    u1=[zeros(1,M-1) u];
    A=zeros(L,M);
    for k=1:L
        A(k,:)=u1(M-1+k:-1:k);
    end
        
    
    %% RLS
    delta=0.004;
    lambda=0.99;
    w_est=zeros(M,L-n0);
    xi=zeros(L,1);
    P=1/delta*eye(M);
    for nn=1:L-n0
        k=1/lambda * P *A(nn,:)'/ ( 1+1/lambda*A(nn,:)*P*A(nn,:)'  );
        xi(nn)=d(nn)-w_est(:,nn)'*A(nn,:)';
        w_est(:,nn+1)=w_est(:,nn)+k*conj(xi(nn));
        P=1/lambda*P-1/lambda*k*A(nn,:)*P;
    end
    w_test=w_test+w_est;
    w_err=abs(w_est-w_theory);
    xi_test=xi_test+abs(xi);
end
w_test=w_test/test_N;
w_err=w_err/test_N;
w_err=w_err.^2;
xi_test=xi_test/test_N;
w_test(:,end)
figure 
plot(w_test(1,:))
hold on
plot(w_test(2,:))
title('100 times average learning curve ')
legend('w1', 'w2');
xlabel('Iteration times')
ylabel('Weight')

figure
plot(w_est(1,:))
hold on
plot(w_est(2,:))
legend('typical w1', 'typical w2');
title('Typical learning curve')
xlabel('Iteration times')
ylabel('Weight')

figure
MSE=xi_test.^2;
semilogy(MSE)
title('RLS learning curve')
xlabel('Iteration times')

figure
semilogy(w_err(1,:))
hold on
semilogy(w_err(2,:))
    