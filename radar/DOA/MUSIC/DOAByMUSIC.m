%% MUSIC 算法
%% LCG UESTC 2020.11.23
% X：N*L;N:阵元个数，L：快拍个数
% d: 阵元间距，lambda：波长
% delta_theta: 谱的横轴间隔，单位：角度
function [theta_x,P_music]=DOAByMUSIC(X,K,d,lambda,delta_theta)
L=size(X,2);
N=size(X,1);
j=sqrt(-1);
R=X*X'/L;
[EV,D]=eig(R);%
EVA=diag(D).';
[~,I]=sort(EVA);%将特征值排序
EV=fliplr(EV(:,I));% 对应特征矢量排序
En=EV(:,K+1:end); 
theta_x=-90:delta_theta:90;
P_music=zeros(1,length(theta_x));
for ii=1:length(theta_x)
    theta_i=theta_x(ii);
    a=exp(-j*(0:N-1)'*2*pi*d/lambda*sin(theta_i/180*pi));
    P_music(ii)=1/(a'*(En*En')*a);
end

end