clear all
close all
j=sqrt(-1);
L=1;  %time of sim
N=2^16; %length of  signal
M=64;   %max delay
n=0:N-1;
f=[0.15,0.17,0.26];
SNR=[20 25 30];
v=sqrt(1/2)*(randn(1,N)+randn(1,N)*j);

for ii=1:L
	phi_k=2*pi*rand(1,3)';             %phase [0 2pi]


	a_k=10.^(SNR/10/2).'.*exp(j*(2*pi*f'.*n+phi_k));       %|a_k|?
    a_k=sum(a_k,1);
	u=a_k+v;     %signal 
	
	figure
	plot(abs(u))
	xlabel('n')
	ylabel('ampltitude')
	title('|u(n)|')
	
	%Autocorrelation  theoretical value
 	m=-M+1:M-1;        %delay of two signal
% 	r_u=sum(diag(a.^2)*exp(j*2*pi*f'*m));
% 	r_u=abs(r_u)/max(abs(r_u));
% 	figure
% 	plot(m,r_u);
% 	xlabel('m')
% 	ylabel('ampltitude')
% 	title('theoretical value of |r(m)|')
	
	%r_1(m)=1/N*\sum{n=0}{N-1}u_N(n)*u_N_*(n-m)  |m|<=N-1
	
	
	figure
	r_1=abs(conv(u,u));
	r_1=r_1(m(1)+N:m(end)+N)/max(r_1);
	plot(m,r_1)
	xlabel('m')
	ylabel('ampltitude')
	title('|r(m)| by conv')
	e1(ii,:)=r_u-r_1;
	%{
	%按书上公式写的，画出来不像,式子可以理解为卷积，然后用自带的conv函数就像了
	%r_1=zeros(1,size(m));
	r_1_m=0;
	for mm=1:size(m,2);
		if m(mm)>=0 
		for nn=m(mm)+1:N
			r_1_m=r_1_m+u(nn)*conj(u(nn-m(mm)));
		end
		else
		for nn=1:N+m(mm);
			r_1_m=r_1_m+u(nn)*conj(u(nn-m(mm)));
		end
		end
	
		r_1(mm)=r_1_m/N;
		r_1_m=0;
	end
	%figure
	%plot(m,r_1)%不像
	%}
    
	%% Autocorrelation function by FFT
	%%自相关函数的幅度怎么确定
	u0=zeros(1,size(u,2));
	u_2N=[u,u0];
	NFFT = 2^nextpow2(size(u_2N,2));
	U_2N=2*fftshift(fft(u_2N,NFFT)/size(u_2N,2));
	S=U_2N.*conj(U_2N).^2/N;
	
	r_0m=size(u_2N,2)*ifft(S);%ifft出来的是复数，应该用绝对值来恢复吗
	r_2=[r_0m(N+2:2*N),r_0m(1:N)];
	r_2=r_2(m(1)+N:m(end)+N);
	r_2=abs(r_2)/max(abs(r_2));
	figure
	plot(m,r_2)
	xlabel('m')
	ylabel('ampltitude')
	title('|r(m)| by FFT')
	e2(ii,:)=r_u-r_2;
	%%
	r_3=xcorr(u);
	r_3=abs(r_3(m(1)+N:m(end)+N))/max(abs(r_3));
	figure
	plot(m,r_3);
	xlabel('m')
	ylabel('ampltitude')
	title('|r(m)| by xcorr function in software')
	e3(ii,:)=r_u-r_3;
	

end
e(1,:)=sum(abs(e1).^2)/L;
e(2,:)=sum(abs(e2).^2)/L;
e(3,:)=sum(abs(e3).^2)/L;

figure
stem(m,e(1,:));
xlabel('m')
ylabel('error value')
title('L=100')
figure
stem(m,e(2,:));
xlabel('m')
ylabel('error value')
title('L=100')
figure
stem(m,e(3,:));
xlabel('m')
ylabel('error value')
title('L=100')

