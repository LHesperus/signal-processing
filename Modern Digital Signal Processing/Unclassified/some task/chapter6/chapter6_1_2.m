clc
clear all
close all

j=sqrt(-1);
%% gen signal 
f=[0.15 0.25 0.30]';
N=500;                      %length of signal
M=6;                           % filter order
SNR=[20 25 30]';
sigma_v=1;                    %noise power
test_N=500;
w_test=0;
xi_test=0;
for test=1:test_N
	v_n=sqrt(sigma_v/2)*randn(1,N)+j*sqrt(sigma_v/2)*randn(1,N);% complex gauss noise
	a_k=sqrt(10.^(SNR/10)*sigma_v);%ampltitude of envelope
		
	n=(0:N-1);
	phi_k=2*pi*rand(1,3)';
	s_k=a_k.*exp(j*(2*pi*f*n+phi_k));
	u_n=sum(s_k)+v_n;
	u_n=u_n.';

    %% Observation Matrix
    A=zeros(N,M);
    u_n=[zeros(M-1,1);u_n];
    for mm=1:M
        A(:,mm)=u_n(M+1-mm:1:N+M-mm)';
    end
    
    %% RLS
    lambda=0.95;
    delta=0.05;
    I=diag(ones(1,M));
    P=1/delta*I;
    w_est=zeros(M,N);
    d=u_n(M+1:end);
    xi=zeros(1,N-2);
    for nn=2:N-1
        k=1/lambda * P *A(nn,:)'/ ( 1+1/lambda*A(nn,:)*P*A(nn,:)'  );
        xi(nn)=d(nn)-w_est(:,nn-1)'*A(nn,:)';
        w_est(:,nn)=w_est(:,nn-1)+k*conj(xi(nn));
        P=1/lambda*P-1/lambda*k*A(nn,:)*P;
    end
      w_test=w_test+w_est;

      xi_test=xi_test+xi;

end
w_test=w_test/test_N;
xi_test=xi_test/test_N;
w_n=1000;
w=2*pi*(-0.5:1/w_n:0.5);
aw=exp(-j*(1:M)'*w);
for ii=1:N-10
sigma=abs(xi_test(ii+1)).^2;
a_k=-conj(w_test(:,ii+1));
    for ww=1:length(w)
        S_AR(ww)=sigma/(1+a_k.'*aw(:,ww))^2;
    end
S_AR=abs(S_AR);
[pks,locs]=findpeaks(S_AR);
    if(size(locs,2)>=3)
        [a,b]=sort(pks);
        f_est=sort(w(locs(b(end:-1:end-2))))/(2*pi);
        err(:,ii)=(f_est'-sort(f)).^2;  
    else
        f_est=[0.5 0.5 0.5];
        err(:,ii)=(f_est'-sort(f)).^2; 
    end
end
figure
plot(10*log10(abs(xi_test).^2))

figure
subplot(3,1,1)
plot(10*log10(err(1,:)))
xlabel('Iteration times')
ylabel('MSE')
title('learning curve of signal 1 ')
subplot(3,1,2)
plot(10*log10(err(2,:)))
xlabel('Iteration times')
ylabel('MSE')
title('learning curve of signal 2 ')
subplot(3,1,3)
plot(10*log10(err(3,:)))
xlabel('Iteration times')
ylabel('MSE')
title('learning curve of signal 3 ')



 figure
 plot(w/(2*pi),10*log10(S_AR))
 ylabel('normalized Power Spectrum /dB')
 xlabel('\omega / 2\pi')
 title('S_{AR}')     

 figure
 semilogy((abs(xi_test).^2))