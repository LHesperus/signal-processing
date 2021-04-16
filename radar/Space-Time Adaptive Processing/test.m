%==========================================================================
% 单基地雷达空时自适应处理基本测试
% 均匀线阵
% 假设信号处理已完成匹配滤波
% 假设空时快拍中存在目标
% 作者：LHesperus
%  空间频率：f_s= d/lambda*sin(theta); theat(-pi,pi)=>f_s=[-0.5,0.5]
%  多普勒频率：fd=2v/lambda*sin(theata);归一化：fd/PRF=fd*PRI
%  杂波脊斜率：beta=fd/f_s=2v/d*PRI
%==========================================================================
clc;clear;close all
j=sqrt(-1);
c=3e8;                              % 光速
%-------------------雷达参数------------------------------------------------
N=16;                               % 天线个数
M=16;                               % 脉冲个数
lambda=c/600e6;                     % 信号波长
d=lambda/2;                         % 线阵间隔
PRI=0.1e-3;                         % 脉冲重复间隔
Vr=200;                             % 平台速度
beta=2*Vr/d*PRI;                    % 地杂波脊斜率
%-------------------目标参数-----------------------------------------------
Vtgt=800;                            % 目标速度
% psi=60/180*pi;                     % 目标锥角
theta=-30/180*pi;                    % 目标方位角
Gtgt=10;                             % 目标匹配滤波后的强度
%-------------------系统性能-----------------------------------------------
Vmax=1/PRI * lambda / 2;
%-------------------构建目标信号-------------------------------------------
SpatialFreqTgt = d./lambda*sin(theta);  %归一化空间频率，注：空间采样间隔=d*sin(theta)/c,fc=c/lambda
fdTgt=2*Vtgt/lambda*sin(theta);            % 多普勒频率
Stgt=kron(exp(j*2*pi*fdTgt*(0:M-1)*PRI),exp(j*2*pi*(0:N-1)*SpatialFreqTgt));%目标空时导向矢量
X=Gtgt*exp(j*2*pi*(0:N-1)'*SpatialFreqTgt).*exp(j*2*pi*fdTgt*(0:M-1)*PRI);%目标空时矩阵 (N*M)

Xfft=fftshift(fft(X,1024,1),1);
Xfft=fftshift(fft(Xfft,1024,2),2);
figure
mesh(abs(Xfft))
title('矩阵行列分别fft后结果')
X=reshape(X,N*M,1);%空时快拍
%===================构建杂波信号===========================================
%-------------------干扰信号-----------------------------------------------
Gj=10;                                  % 干扰幅度
theta_j=20/180*pi;                      % 干扰方向
SpatialFreqJ = d./lambda*sin(theta_j);  % 空间频率
As=exp(-j*2*pi*(0:N-1)'*SpatialFreqJ);
Ij=Gj*diag(ones(1,M));
Rj=kron(Ij,conj(As)*As.');              %协方差矩阵(Ward,1995)

figure
mesh(abs(Rj));title('空时干扰信号协方差矩阵')
%-------------------地杂波-------------------------------------------------
% Rc;
%-------------------高斯噪声-----------------------------------------------
Rn=diag(0.1*ones(1,N*M));
%-------------------空时功率谱估计------------------------------------------

Ri=Rj+Rn;
w=Ri\(Stgt.');  % STAP 最优权
R=X*X'/length(X);

R=R+Ri;
f_ns=d/lambda*linspace(-1,1,100);%归一化空间频率
f_nt=linspace(-0.5,0.5,100);     %归一化多普勒频率
P=zeros(length(f_ns),length(f_nt));Pw1=P;
invR=inv(R);
for ii=1:length(f_ns)
    As=exp(-j*2*pi*(0:N-1)*f_ns(ii));
    for jj=1:length(f_nt)
        At=exp(-j*2*pi*(0:M-1)*f_nt(jj));
        S=kron(At,As);%空时导向矢量
        P(ii,jj)=1/(S*invR*S');         % 信号谱
        Pw1(ii,jj) = abs(w'*S')^2;      % STAP
    end
end

figure
mesh(abs(P))
figure
mesh(abs(Pw1))
