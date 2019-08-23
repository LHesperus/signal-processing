%% ***************数字通信系统****************************%
%该通信系统能够实现简单的通信过程。系统包括映射、成形滤波、混频、解调、匹配滤波等模块。
%系统参数：   载波频率：2000 Hz
%                  符号速率：1000 B
%                  调制方式：QPSK
%                  采样速率：16000 Hz  
%                  脉冲成形使用根方升余弦滤波器，长度为8 和16 
%                  滚降因子：0.1,0.25,0.5

%作者：张康俐     时间：2011年11月8日

%% *****************************************************%

clear all;
close all;
clc
%% 参数设置
    fc = 2000;                                                        %载频为2000Hz
    R = 1000;                                                         %信息速率1000B
    Rs = 16000;                                                      %采样速率16kHz
    nsamp=Rs/R;                                                    %过采样速率
    n = 1000;                                                       %产生的信息序列个数
    foff =10;                                                          %频偏
    poff =10;                                                           %相偏
    toff =10;                                                          %时偏
    %成形脉冲参数设置
    delay = 8;                                                         %延时
    rolloff = 0.5;                                                     %滚降系数
    snr = 20;                                                          %信噪比/dB   
%% 发射端
%%产生信号
    %info = randint(n,1);                                           %产生随机序列
    info = randi([0,1],n,1);                                           %产生随机序列
    train=[1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 ];              %产生训练序列
    info1=[train info'];
    info1 = reshape(info1,2,[]);                                %进行串并变换
    info_I = info1(1,:);                                             %I路信息序列
    info_Q= info1(2,:);                                            %Q路信息序列

%%映射
    for i=1:length(info_I)
        if info_I(i)==0                                               %若信息比特为0，则映射为－1
            info_I(i)=-1;
        end
        if info_Q(i)==0 
           info_Q(i)=-1;
        end
    end

    symbol = info_I+j*info_Q;                                  %信息序列的解析形式

%%脉冲成型
    rrcfilter = rcosine(R,Rs,'fir/sqrt',rolloff,delay);      %产生一个均方升余弦脉冲
% 画脉冲图
%figure
%impz(rrcfilter,1);
%title('成形脉冲')

%用产生的脉冲对映射后的信息进行脉冲成形
    I = rcosflt(info_I,R,Rs,'filter',rrcfilter);                  %I路基带信号
    Q = rcosflt(info_Q,R,Rs,'filter',rrcfilter);               %Q路基带信号

%%调制
%产生载波信号
    t = 0:1/Rs:10;
    carrier1 = sqrt(2)*cos(2*pi*fc*t);                        %产生两路正交的载波信号
    carrier2 = -sqrt(2)*sin(2*pi*fc*t);
%画出其中一路载波信号
%figure
%plot(carrier2(1:100))
%混频
    I_passband = I'.*carrier1(1:length(I));                  %I路带通信号
    Q_passband= Q'.*carrier2(1:length(Q));               %Q路带通信号
    s = I_passband+Q_passband;  %产生发射信号
%画发射信号的功率谱
%S = spectrum.periodogram;
%psd(S,s,'Fs',Rs)

%% 过多径信道
chan=[1 0.5 0.3];                                                  %产生ISI信道
chanup=upsample(chan,Rs/R);
r_inter=filter(chanup,1,s);
    
%% 过AWGN信道
    r = awgn(s,snr,'measured');                               %加噪声
    %r = awgn(r_inter,snr,'measured'); 
    %r=s;

%% 接收端
%产生解调载波
    t = 0:1/Rs:10;
    rcarrier1 = sqrt(2)*cos(2*pi*(fc+foff)*t+poff);     %产生两路正交的载波信号
    rcarrier2 = -sqrt(2)*sin(2*pi*(fc+foff)*t+poff);
%%解调
    rI=r.*rcarrier1(1:length(r));                                  
    rQ=r.*rcarrier2(1:length(r));
%%匹配滤波
    rI_low = rcosflt(rI,Rs,Rs,'filter',rrcfilter);               %I路匹配滤波信号
    rQ_low = rcosflt(rQ,Rs,Rs,'filter',rrcfilter);            %Q匹配滤波路信号
%画出I路匹配滤波后的信号
%figure
%plot(rI_low)
r_low = rI_low+j*rQ_low;
%观察眼图
%eyediagram(r_low(257:length(r_low)-255-16),2*Rs/R);
%title('接收端眼图')

    rI_bit = [];                                                         %定义I路判决信息序列
    rQ_bit = [];                                                        %定义Q路判决信息序列
    y1 = [];
    y2 = [];
for i=toff+1:nsamp:(length(rI_low)-4*delay*nsamp+toff-nsamp+1)
     rI_bit((i-1-toff)/nsamp+1)=rI_low(i);
     rQ_bit((i-1-toff)/nsamp+1)=rQ_low(i);
end
    ysymbol =  rI_bit+j*rQ_bit;                                %未同步的接收信号
%观察接收端的星座图
constell_uti=scatterplot(ysymbol,1,0,'b.');               %画出未定时恢复的星座图
hold on;
scatterplot(symbol,1,0,'r*',constell_uti)                   %画出理想星座图
title('接收端星座图')
%rI_lowsamp = Gardner(rI_low,nsamp,toff);
%rQ_lowsamp = Gardner(rQ_low,nsamp,toff);
%r_lowsamp=rI_lowsamp+j*rQ_lowsamp;
r_low=phase_frequence_recover(r_low,length(r_low));%对频偏相偏进行校正
r_lowsamp = Gardner_timing(r_low,nsamp,toff);     %用Gardner算法进行定时恢复
constell_ti=scatterplot(r_lowsamp,1,0,'b.');             %画出定时恢复后的星座图
hold on;
scatterplot(symbol,1,0,'r*',constell_ti)                     %画出理想星座图
title('同步后的星座图')
%符号判决
    for i=1:length(r_lowsamp)                                 %确定判决时刻进行判决，判决门限为0，信号幅度大于0则判为1，否则判为0
        if  real(r_lowsamp(i))>0
            y1(i)=1;
        else
            y1(i)=0;
        end
        if  imag(r_lowsamp(i))>0
            y2(i)=1;
        else
            y2(i)=0;
        end
    end 
    
%进行串并变化
     y = [y1;y2];                                                     %串并变换
    recover_info = reshape(y,[],1);                           %接收端输出序列     
%% 计算误码率
    location=conv(recover_info,train);
   % figure
    %plot(location)
    [largest,head]=max(location(1:end-n-length(train)));
    recover_info=recover_info(head+1:head+n);
    count=0;
    error = info-recover_info;
    for i=1:n
        if error(i)~=0
            count=count+1;
        end
    end
    snr                                                                   %信噪比
    BER=count/n                                                    %输出误码率    
    


