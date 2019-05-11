clear all
close all
j=sqrt(-1);
N=2^16; %length of  signal
M=64;   %max delay
n=0:N-1;
f=[0.15,0.17,0.26];
phi_k=2*pi*rand(1,3);             %phase [0 2pi]
a=rand(1,3);
a_k=a.*exp(j*phi_k);       %|a_k|?
s_1=a_k(1)*exp(j*2*pi*f(1)*n);
s_2=a_k(2)*exp(j*2*pi*f(2)*n);
s_3=a_k(3)*exp(j*2*pi*f(3)*n);
s_n=[s_1;s_2;s_3];
v_1=awgn(s_1,20,'measured');
v_2=awgn(s_2,25,'measured');
v_3=awgn(s_3,30,'measured');
v=[v_1;v_2;v_3];
u=sum(s_n+v);     %signal 

figure
plot(abs(u))

%Autocorrelation  theoretical value
m=-M+1:M-1;        %delay of two signal
r_u=sum(diag(a.^2)*exp(j*2*pi*f'*m));
figure
plot(m,abs(r_u));




%r_1(m)=1/N*\sum{n=0}{N-1}u_N(n)*u_N_*(n-m)  |m|<=N-1

r_1=zeros(1,size(m));
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
figure
plot(m,r_1)%不像

%% Autocorrelation function by FFT
%%自相关函数的幅度怎么确定
u0=zeros(1,size(u,2));
u_2N=[u,u0];
NFFT = 2^nextpow2(size(u_2N,2));
U_2N=2*fftshift(fft(u_2N,NFFT)/size(u_2N,2));
S=U_2N.*conj(U_2N).^2/N;

r_0m=size(u_2N,2)*ifft(S);%ifft出来的是复数，应该用绝对值来恢复吗
r_2=[r_0m(N+2:2*N),r_0m(1:N)];
figure
plot(m,abs(r_2(m(1)+N:m(end)+N)))


%%
r_3=xcorr(u);
figure
plot(m,abs(r_3(m(1)+N:m(end)+N)));