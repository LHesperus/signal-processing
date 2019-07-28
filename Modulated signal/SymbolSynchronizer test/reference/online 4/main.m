clear;clc;close all
%16QAM
iii=[1] ;                                        % 采样时偏
EbNo_dB=1:30;                                    % 循环次数
for i=1:length(EbNo_dB)                          % EbNo(dB)

%%%%%%%%% 发射部分 %%%%%%%%%%%%%%
datalength=20000;
data=sign(rand(1,datalength)-0.5);               % 输入双极性随机数据
% 参数定义 
Fd=1;                                            % 码元速率
Fs=Fd*32;                                        % 系统采样频率
Fc=Fd*4;                                         % 载波频率
Nsamp=Fs/Fd;                                     % 每符号采样数
% 串并变换
dataI = data(1:2:length(data));                  % I路
dataQ = data(2:2:length(data));                  % Q路
% 2/4电平变换且补零生成脉冲信号
[II_four] = twoTOfour(dataI);
[QQ_four] = twoTOfour(dataQ);
II_four_pulse=zeros(1,datalength/4*Nsamp);
QQ_four_pulse=zeros(1,datalength/4*Nsamp);
II_four_pulse(1:Nsamp:datalength/4*Nsamp)=II_four;
QQ_four_pulse(1:Nsamp:datalength/4*Nsamp)=QQ_four;
% 根升余弦滤波器成形滤波
alfa=0.9;
[num,den] = rcosine(Fd,Fs,'fir/sqrt',alfa,3);
II_shape=filter(num,den,II_four_pulse);
QQ_shape=filter(num,den,QQ_four_pulse);
% 与载频相乘
t=0:1/Fs:1/Fs*(length(II_shape)-1);
II = II_shape.*cos(2*pi*Fc*t);
QQ = QQ_shape.*sin(2*pi*Fc*t);
% 16QAM信号
Sym_16QAM = II+QQ;

%%%%%%%%% 高斯信道 %%%%%%%%%%%%%%
snr = EbNo_dB(i) + 10*log10(4) - 10*log10(Nsamp);
Sym_16QAM = awgn(Sym_16QAM,snr,'measured');      % 高斯白噪声信道

%%%%%%%%% 接收部分 %%%%%%%%%%%%%%
% 混频
II_r = Sym_16QAM.*cos(2*pi*Fc*t);
QQ_r = Sym_16QAM.*sin(2*pi*Fc*t);
% 匹配滤波
II_m0=filter(num,den,II_r);
QQ_m0=filter(num,den,QQ_r);
 %eyediagram(II_m0(106:4000),96);                % 眼图

% % 预滤波

% 固定时钟采样
II_m0=II_m0(iii:end);
QQ_m0=QQ_m0(iii:end);
Fs_s=4*Fd;                                       % 每符号采4个点
II_m=intdump([II_m0,zeros(1,iii-1)],Fs/Fs_s);
QQ_m=intdump([QQ_m0,zeros(1,iii-1)],Fs/Fs_s);
% 定时
w=[0.5,zeros(1,datalength/4-1)];
q=[0.9,zeros(1,datalength-1)];
q_temp=[q(1),zeros(1,datalength-1)];
u=[0.6,zeros(1,datalength/2-1)];
m=1; s=1; k=1; 
strobe=zeros(1,datalength);
time_error=zeros(1,datalength/4);
Kd=6;
Wn=0.01;
C1=2*Wn*0.707/Kd; C2=Wn^2/Kd;
for m=1:(length(II_m)-5)
    q_temp(m+1)=q(m)-w(s);
    if q_temp(m+1)<0
        q(m+1)=mod(q_temp(m+1),1);
        k=k+1;
        strobe=mod(k,2);
        u(k)=q(m)/w(s);                                         
        C_02= (1/6)*u(k)^3+(-1/6)*u(k);       
        C_01= (-1/2)*u(k)^3+(1/2)*u(k)^2+(1)*u(k);
        C_0 = (1/2)*u(k)^3+(-1)*u(k)^2+(-1/2)*u(k)+1;
        C_1 = (-1/6)*u(k)^3+(1/2)*u(k)^2+(-1/3)*u(k);         
        yi_I(k)=C_02*II_m(m+2) + C_01*II_m(m+1) + C_0*II_m(m) + C_1*II_m(m-1);
        yi_Q(k)=C_02*QQ_m(m+2) + C_01*QQ_m(m+1) + C_0*QQ_m(m) + C_1*QQ_m(m-1);
        if strobe==0
            if k>2
               time_error(s)=yi_I(k-1)*(yi_I(k)-yi_I(k-2))+yi_Q(k-1)*(yi_Q(k)-yi_Q(k-2)); 
            else
               time_error(s)=yi_I(k-1)*yi_I(k)+yi_Q(k-1)*yi_Q(k);  
            end
            if s>1
               w(s+1)=w(s)+C1*(time_error(s)-time_error(s-1))+C2*time_error(s);   
            else
               w(s+1)=w(s)+C1*time_error(s)+C2*time_error(s); 
            end
            s=s+1;
        end
    else
        q(m+1)=q_temp(m+1);
    end
end
ni=max(yi_I);
nq=max(yi_Q);
yi_II=yi_I(2:2:end)/ni;
yi_QQ=yi_Q(2:2:end)/nq;
% 4/2电平变换且判决
[yi_II_judge] = judge(yi_II);
[yi_II_two] = fourTOtwo(yi_II_judge);
[yi_QQ_judge] = judge(yi_QQ);
[yi_QQ_two] = fourTOtwo(yi_QQ_judge);
% scatterplot(yi_II+j*yi_QQ);                    % 星座图
% 并串变换
recp_Data=zeros(1,length(yi_II_two)+length(yi_QQ_two));
recp_Data(1:2:length(recp_Data))=yi_II_two;
recp_Data(2:2:length(recp_Data))=yi_QQ_two;
% 误码率
[nnum,rt]= symerr(recp_Data(2021:(datalength-500+21)),data(2001:(datalength-500+1)))

% meanx(i)=mean(time_error);                     % 定时误差提取模块输出time_error
% t_tempx=var(time_error);
% t_varx(i)=sqrt(t_tempx);
% meany(i)=mean(w);                              % 环路滤波器输出w
% t_tempy=var(w);
% t_vary(i)=sqrt(t_tempy);  
% meanz(i)=mean(u);                              % 插值位置小数部分u
% t_tempz=var(u);
% t_varz(i)=sqrt(t_tempz);  

rat(i)=rt;
end
semilogy(EbNo_dB,rat,'*-');grid;
% axis([7 13 10^(-4) 1]);
xlabel('snr(dB)');ylabel('BER');
hold on;


% figure(3);
% subplot(3,1,1),stem(II_four(2500:2600));legend('II_four');grid;
% subplot(3,1,2),stem(yi_II_judge(2500:2600));legend('II_shape');grid;
% subplot(3,1,3),stem(yi_II(2500:2600));legend('II_shape');grid;
% subplot(3,1,1),stem(QQ_four(1:100));legend('II_four');grid;
% subplot(3,1,2),stem(yi_QQ_judge(1:100));legend('II_shape');grid;
% subplot(3,1,3),stem(yi_QQ(1:100));legend('II_shape');grid;
% subplot(3,1,1),stem(II_four(1:20));legend('II_four_rect');grid;
% subplot(3,1,2),stem(II_four_pulse(1:240));legend('rcosine');grid;
% subplot(3,1,3),stem(II_m(1:240));legend('rcosine');grid;

% 理论误码率
SNRindB=0:1:15;
M=16;
k=log2(M);
for i=1:length(SNRindB)
    SNR=exp(SNRindB(i)*log(10)/10);
    theo_err(i)=1-(1-3/2*qfunc(sqrt(3*k*SNR/(M-1)))).^2;
%     theo_err(i)=4*Qfunc(sqrt(3*k*SNR/(M-1)));
end
semilogy(SNRindB,theo_err);
grid on;

figure;plot(II_m0+QQ_m0*j,'x')
figure;plot(II_m+QQ_m*j,'x')
figure;plot(yi_I+yi_Q*j,'x')
figure;plot(yi_II+yi_QQ*j,'x')