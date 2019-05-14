%gen MSK by Quadrature
%s_k(t)=p_k*cos(pi*t/(2*T_s))cos(w_c*t)-q_k*sin(pi*t/(2*T_s))sin(w_c*t)
%(k-1)T_s<t<=k*T_S
clc
clear

Rs=1e3;                                        %bit ratio
Ts=1/Rs;
N=100;                                          %Number of bits to process
fc=3e3;                                        %carrier frequency
fs=1e4;                                        %sample frequency
T=1/fs;
t=(0:(round(N*Ts/T)-1))*T;
r=round(Ts/T);
%% Orthogonal carrier wave
xc=cos(2*pi*fc*t);
xs=sin(2*pi*fc*t);
%% gengerate bit sequence
a=2*(rand(1,N)>0.5)-1;
%a=[1,1,-1,1,-1,-1,1,1,-1,1] %%test signal
%a=[1,1,1,-1,-1,1,1,1,-1,-1]
a_sample=repmat(a,r,1);
a_sample=a_sample(:)';
subplot(6,1,1)
plot(a_sample)
set(gca,'xticklabel',[]);
set(gca,'position',[0.15 5.1/6 0.75 0.9/6])
axis([0 length(a_sample) -2 2])
ylabel('a(t)')
%% Differential coding

b=ones(1,N);
b(1)=a(1);
for jj=2:N
   if a(jj)==1
       b(jj)=b(jj-1);
   else
       b(jj)=-b(jj-1);
   end
end

b_sample=repmat(b,r,1);
b_sample=b_sample(:)';
subplot(6,1,2);
plot(b_sample)
set(gca,'xticklabel',[]);
set(gca,'position',[0.15 4.1/6 0.75 0.9/6])
axis([0 length(b_sample) -2 2])
ylabel('b(t)')

%% serial to parallel conversion
%b1b2b3b4b5b6b7b8=p1q2p3q4p5q6
%b1=p1=p2,b2=q2=q3
%p_k:p1p2p3p4p5p6p7=b1b1b3b3b5b5b7
%q_k:q1q2q3q4q5q6q7q8=b0b2b2b4b4b6b6b8
%At present, I don't know how to get the value of b0 p0 and q0 ,
%Suppose b0=a0,p0=cos(\phi_{0})=1,q0=b0
b_odd=b(1:2:end);
b_even=b(2:2:end);
p=reshape([b_even;b_even],1,[]);
p=[1,p(1:end-1)];
q=reshape([b_odd;b_odd],1,[]);

%% plot p(t)
p_sample=repmat(p,r,1);
p_sample=p_sample(:)';
subplot(6,1,3);
plot(p_sample)
set(gca,'xticklabel',[]);
set(gca,'position',[0.15 3.1/6 0.75 0.9/6])
axis([0 length(p_sample) -2 2])
ylabel('p(t)')
%% plot q(t)
q_sample=repmat(q,r,1);
q_sample=q_sample(:)';
subplot(6,1,4);
plot(q_sample);
set(gca,'xticklabel',[]);
set(gca,'position',[0.15 2.2/6 0.75 0.8/6])
axis([0 length(q_sample) -2 2])
ylabel('q(t)')

%% plot p_sample.*cos(pi*t/(2*Ts))
subplot(6,1,5);
plot(p_sample.*cos(pi*t/(2*Ts)));
set(gca,'xticklabel',[]);
set(gca,'position',[0.15 1.4/6 0.75 0.7/6])
axis([0 length(q_sample) -1 1])
ylabel('p*cos(\pi*t/(2*Ts)')

%% plot q_sample.*sin(pi*t/(2*Ts))
subplot(6,1,6)
plot(q_sample.*sin(pi*t/(2*Ts)))
%set(gca,'xticklabel',[]);
set(gca,'position',[0.15 1/12 0.75 0.8/6])
xlabel('time')
ylabel('q*sin(\pi*t/(2*Ts)')

%% s: MSK signal
s=p_sample.*cos(pi*t/(2*Ts)).*xc-q_sample.*sin(pi*t/(2*Ts)).*xs;
figure
plot(s)
title('MSK')
figure
plotSpectral(s,fs);

%% plot additive phase
%theta_k(t)=a_k*pi/(2*T_s)*t+phi
phi=zeros(1,N);
for jj=2:N
    phi(jj)=phi(jj-1)+(jj-1)*pi/2*(a(jj-1)-a(jj));
end
%phi=mod(phi,2*pi)
phi=repmat(phi,r,1);
phi=phi(:)';
theta=(a_sample*pi)/(2*Ts).*t+phi;
theta=wrapToPi(theta);
plot(theta,'r')
set(gca,'YTick',-pi:pi/2:pi)
set(gca,'YTickLabel',{'-pi','-pi/2','0','pi/2','pi'})
ylabel('\theta_{k}(t)')
xlabel('time')
title('additive phase (mod 2\pi)')
grid on

