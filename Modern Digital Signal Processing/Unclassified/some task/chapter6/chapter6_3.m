clc
clear all
close all
j=sqrt(-1);

L=1000   ;            %signal length
sigma_v_2=0.0731;      %noise power

	v=sqrt(sigma_v_2)*randn(1,L);
	b=1;
	a=[1 -0.975 0.95];
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
    w_est=zeros(M,L+1);
    xi=zeros(L,1);
    P=1/delta*eye(M);
    for nn=1:L-n0
        k=1/lambda * P *A(nn,:)'/ ( 1+1/lambda*A(nn,:)*P*A(nn,:)'  );
        xi(nn)=d(nn)-w_est(:,nn)'*A(nn,:)';
        w_est(:,nn+1)=w_est(:,nn)+k*conj(xi(nn));
        P=1/lambda*P-1/lambda*k*A(nn,:)*P;
    end
    semilogy(abs(xi).^2)
    figure
    plot(w_est(1,:))
    hold on
    plot(w_est(2,:))


    