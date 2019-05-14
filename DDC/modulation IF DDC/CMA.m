function [ yk,e,weight] = CMA( signal, Lf,delt, p)
% Lf=10;
% delt=0.001;                        %步长因子为0.001s
% p = 2;
S_ref_n=signal/max(signal)*2;
yk=zeros(1,length(S_ref_n));
e=zeros(1,length(S_ref_n));

R_1=sum(abs(S_ref_n).^(2*p))/sum(abs(S_ref_n).^p);
weight=zeros(length(S_ref_n),Lf+1);                 % 权重因子，假设为一个信号接收通道，进行101步时间延迟处理 ，权重因子即为1*101的矩阵
weight(:,Lf/2-1)=1;                         %令第51个权重为1，其他为0，作为最初赋值
for j=Lf/2+1:length(S_ref_n)-Lf/2
   yk(j)=S_ref_n(j+Lf/2:-1:j-Lf/2)*conj(weight(j,:)');
   e(j)=(abs(yk(j)).^2-R_1)*yk(j);
   weight(j+1,:)=weight(j,:)-delt*e(j)*conj(S_ref_n(j+Lf/2:-1:j-Lf/2));
end


end

