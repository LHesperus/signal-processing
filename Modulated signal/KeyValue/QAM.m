% MQAM 
%
% M=4¡¢16¡¢64¡¢256  constellation diagram:Square
%(constellation diagram)every row or column has M^(1/2) points
% The data corresponding to the points in each row or column of 
% a constellation diagram consists of Gray code.Assume the bit 
% of digits per Grey is x,then 2^x=M^(1/2),=>x=log4(M),
% x is also the number of every group of data for IorQ.  
%external function:gen_gray_code.m
clc
clear
j=sqrt(-1);
M=64;
N=log2(M);                                                    %number of modulation levels
x=log(M)/log(4);
SN=10000;                                                      %number of symbols
L=N*SN;                                                       %length of bit stream
Rs=1e3;
%****************quadrature carrier****************************************
fs=1e5;                                                       %sample frequency
ts=1/fs;
Lsamples=L/Rs*fs;                                             %length of sample 
t=(0:Lsamples-1)*ts;
fc=1e4;                                                       %carrier frequency
xc=cos(2*pi*fc*t);
xs=sin(2*pi*fc*t);
%****************generate binary sequences********************************
data_src=rand(1,L)>0.5;                                       

%*****************serial-to-parallel conversion **************************
dataI=data_src(1:2:end);
dataQ=data_src(2:2:end);
%******************2 to N by constellation diagram************************
A=1/(sqrt(2)*(2^(N/2)-1));                                    %Fixed amplitude of constellation diagram,and Make the maximum amplitude 1  
iq_axis=-(2^(N/2)-1):2:(2^(N/2)-1);                           %The Position of Points in Constellation
iq_axis=A*iq_axis;
graycode=gen_gray_code(N/2);                                  %every row is a gray code

i_axis=zeros(1,SN);
q_axis=zeros(1,SN);
%Correspond IQ data to constellation map
for i=1:SN
    temp=dataI(x*(i-1)+1:x*i);
    temp=repmat(temp,2^x,1);
    II=~xor(temp,graycode);
    II=sum(II,2);
    i_axis(i)=iq_axis(find(II==0));
    
    temp=dataQ(x*(i-1)+1:x*i);
    temp=repmat(temp,2^x,1);
    QQ=~xor(temp,graycode);
    QQ=sum(QQ,2);
    q_axis(i)=iq_axis(find(QQ==0));
end
s=i_axis+j*q_axis;                                           

rate_ratio=size(xc,2)/size(i_axis,2);
i_axis=repmat(i_axis,rate_ratio,1);                          %Expanding data to match the length of carrier data
i_axis=i_axis(:)';
q_axis=repmat(q_axis,rate_ratio,1);
q_axis=q_axis(:)';
%**************************generate MQAM signal**************************
MQAM=i_axis.*xc+q_axis.*xs;
figure(1)
plot(MQAM)
figure(2)
plotSpectral(MQAM,fs);
figure(3)
plot(s,'o');grid on;axis('equal',[-10 10 -10 10]);