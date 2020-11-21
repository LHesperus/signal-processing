% 得到data的概率密度函数
% N:划分区间的个数
% cdf:cumsum(y)
function [x,y]=getPDF(data,N)
maxv=max(data);
minv=min(data);
x=linspace(minv,maxv,N);
y=hist(data,x)/length(data);%计算各个区间的个数
% figure
% bar(x,y)%画出概率密度分布图
end

