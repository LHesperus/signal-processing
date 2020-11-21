%% 莱斯分布随机数
% Author：LCG  UESTC 2020.11.21
% ref :雷达地海杂波测量与建模，p256
clc;
clear 
close all
%% Rician
L=10000;
rho=2;
sigma=0.5;
data=random('Rician',rho,sigma,[1,L]);
[x,y]=getPDF(data,200);
pdf_v = pdf('Rician',x,rho,sigma);
cdf_v=1-cdf('Rician',x,rho,sigma);
figure
subplot(221);bar(x,y);title('pdf by data')
subplot(222);plot(x,pdf_v);title('pdf by formula')
subplot(223);semilogy(x,cdf_v);title('cdf');ylabel('1-CDF')
subplot(224);plot(data);title('data')
suptitle(['Rician distribution: ','\rho=',num2str(rho),' \sigma=',num2str(sigma)])

