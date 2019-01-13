% MQAM 
%
% M=4¡¢16¡¢64¡¢256  constellation diagram:Square
%(constellation diagram)every row or column has M^(1/2) points
% The data corresponding to the points in each row or column of 
% a constellation diagram consists of Gray code.Assume the bit 
% of digits per Grey is x,then 2^x=M^(1/2),=>x=log4(M),
% x is also the number of every group of data for IorQ.  
clc
clear
M=64;
N=log2(M);                                                    %number of modulation levels
x=log(M)/log(4);
SN=1000;                                                      %number of symbols
L=N*SN;                                                       %length of bit stream
Rs=1e3;
%****************quadrature carrier****************************************
fs=1e5;
ts=1/fs;
Lsamples=L/Rs*fs;
t=(0:Lsamples-1)*ts;
fc=1e4;
xc=cos(2*pi*fc*t);
xs=sin(2*pi*fc*t);
%****************generate binary sequences********************************
data_src=rand(1,L)>0.5;                                       

%*****************serial-to-parallel conversion **************************
dataI=data_src(1:2:end);
dataQ=data_src(2:2:end);
%******************2 to N by constellation diagram************************
%
%I axis:
%Q axis:
A=1;                                                          %Fixed amplitude of constellation diagram  
iq_axis=-(2^(N/2)-1):2:(2^(N/2)-1);
iq_axis=A*iq_axis;
graycode=gen_gray_code(N/2);                                  %every row is a gray code

i_axis=zeros(1,SN);
q_axis=zeros(1,SN);
for i=1:SN
    temp=dataI(x*(i-1)+1:x*i);
    temp=repmat(temp,2^x,1);
    II=~xor(temp,graycode);
    II=sum(II,2);
    i_axis(i)=find(II==0);
    
    temp=dataQ(x*(i-1)+1:x*i);
    temp=repmat(temp,2^x,1);
    QQ=~xor(temp,graycode);
    QQ=sum(QQ,2);
    q_axis(i)=find(QQ==0);
end
rate_ratio=size(xc,2)/size(i_axis,2);
i_axis=repmat(i_axis,rate_ratio,1);
i_axis=i_axis(:)';
q_axis=repmat(q_axis,rate_ratio,1);
q_axis=q_axis(:)';
%**************************generate MQAM signal**************************
MQAM=i_axis.*xc+q_axis.*xs;
figure(1)
plot(MQAM)
figure(2)
plotSpectral(MQAM,fs)
