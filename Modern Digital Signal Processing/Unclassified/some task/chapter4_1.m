clc
clear all
close all

N=16;
L=10000;            %signal length
n=(0:L-1);
phi=2*pi*rand;    %Initial phase
s=sin(2*pi/N*n+phi);
d=2*cos(2*pi/N*n+phi);

sigma_v_2=2;      %noise power
sigma_s=mean(s.^2);%signal power
SNR=10*log10(sigma_s/sigma_v_2);

u=awgn(s,SNR,'measured');
%figure
%plot(s)
%figure
%plot(u)

for m=0:L-1
    r_n(m+1)=sum(conj(u(1:L-m)).*u(m+1:L))/L;
end

% p(-n)
for m=0:L-1
    p_neg_n(m+1)=sum(u(1:L-m).*conj(d(m+1:L)))/L;
end

R=[r_n(1) r_n(2);r_n(2)' r_n(1)];
p=[p_neg_n(1) p_neg_n(2)]';
w0=inv(R)*p
w_0=linspace(-10,10,100);
w_1=linspace(-10,10,100);
for ii=1:length(w_0)
    for jj=1:length(w_1)
        w=[w_0(ii);w_1(jj)];
        J_w(ii,jj)=mean(d.^2)-2*conj(p)'*w+conj(w)'*R*w;
    end
end
[w_0,w_1] = meshgrid(linspace(-10,10,100));
figure
surf(w_0,w_1,J_w)
xlabel('w_0')
ylabel('w_1')
zlabel('MSE')
J_min=mean(d.^2)-conj(p)'*w0

w=zeros(2,1);
[V,D] = eig(R);
lamada_max=max(diag(D));
mu_max=2/lamada_max;
mu=0.1   ;
for ii=1:100
  w(:,ii+1)=w(:,ii)+mu*(p-R*w(:,ii));
  J(ii)=mean(d.^2)-conj(p)'*w(:,ii);
end
figure
plot(J)
xlabel('Iteration times')
ylabel('J(n)')

figure
plot(w(1,:))
hold on
plot(w(2,:))
%axis([0,100,-2,1])
legend('w_0','w_1')