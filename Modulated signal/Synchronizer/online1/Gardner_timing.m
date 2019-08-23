%% 定时同步（Gardner算法）
%*****该算法比Gardner文章中介绍的算法要简化一些，不用设计环路滤波器参数，
%*****只需设计一个调节步长即可找到插值位置，不过要计算插值位置的整数部分。
%*****参数说明：r_low是接收序列，nsamp是系统的过采样率，start是时偏
function r_lowsamp=Gardner_timing(r_low,nsamp,start)
% 定义立方插值滤波器系数
C_2 = inline('(1/6)*u^3-(1/6)*u');
C_1 = inline('(-1/2)*u^3+(1/2)*u^2+u');
C0  = inline('(1/2)*u^3-u^2-(1/2)*u+1');
C1  = inline('(-1/6)*u^3+(1/2)*u^2-(1/3)*u');
Gain=0.25;

num=1;
time_error=0;                                                       %定时误差
inter_pos=start+nsamp;                                        %插值位置
ted_data1=r_low(start+1);                                     %定时误差监测数据
ted_data2=r_low(start+nsamp/2);
while(inter_pos<length(r_low)-3*nsamp-start)
%前半部分插值 
    mk=round(inter_pos);                                       % 整数部分
    uk=inter_pos-mk;                                            % 小数部分
    fraction(num)=uk;
    inter_data=C_2(uk)*r_low(mk+3)+C_1(uk)*r_low(mk+2)+C0(uk)*r_low(mk+1)+C1(uk)*r_low(mk);%前向插值
    r_lowsamp(num)=inter_data;
    ted_data3=inter_data;
    inter_pos=inter_pos+nsamp/2+time_error;
    TED=sign(real(ted_data1-ted_data3))*sign(real(ted_data2));%一个检测误差插值两次
    time_error=TED*Gain;                                       %定时误差
    ted_out(num)=time_error;
%后半部分插值
    mk=round(inter_pos);
    uk=inter_pos-mk;
    inter_data=C_2(uk)*r_low(mk+3)+C_1(uk)*r_low(mk+2)+C0(uk)*r_low(mk+1)+C1(uk)*r_low(mk);%后向插值
    inter_pos=inter_pos+nsamp/2+time_error;
    ted_data1=ted_data3;
    ted_data2=inter_data;  
    num=num+1;
end 
%figure
%plot(fraction(1:100))
 %ylim([-0.5 0.5]);