%% 对数正态分布随机数
% Author：LCG  UESTC 2020.11.21
% ref :雷达地海杂波测量与建模，p258
clc;
clear 
close all
%% Lognormal
L=10000;
mu=1;
sigma=0.9;
data=random('Lognormal',mu,sigma,[1,L]);
[x,y]=getPDF(data,200);
pdf_v = pdf('Lognormal',x,mu,sigma);
cdf_v=1-cdf('Lognormal',x,mu,sigma);
figure
subplot(221);bar(x,y);title('pdf by data')
subplot(222);plot(x,pdf_v);title('pdf by formula')
subplot(223);semilogy(x,cdf_v);title('cdf');ylabel('1-CDF')
subplot(224);plot(data);title('data')
suptitle(['Lognormal distribution: ','\mu=',num2str(mu),' \sigma=',num2str(sigma)])

