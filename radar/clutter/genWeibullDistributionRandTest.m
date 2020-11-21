%% weibull分布随机数
% Author：LCG  UESTC 2020.11.21
% ref :雷达地海杂波测量与建模，p258
clc;
clear 
close all
%% weibull
L=10000;
b=1;
v=1.8;
data=random('weibull',b,v,[1,L]);
[x,y]=getPDF(data,200);
pdf_v = pdf('weibull',x,b,v);
cdf_v=1-cdf('weibull',x,b,v);
figure
subplot(221);bar(x,y);title('pdf by data')
subplot(222);plot(x,pdf_v);title('pdf by formula')
subplot(223);semilogy(x,cdf_v);title('cdf');ylabel('1-CDF')
subplot(224);plot(data);title('data')
suptitle(['weibull distribution: ','b=',num2str(b),' v=',num2str(v)])

