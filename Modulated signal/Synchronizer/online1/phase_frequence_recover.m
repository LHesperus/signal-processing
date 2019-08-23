%% 载波同步（锁相环法）
%*****该算法能够对接收端载波存在的相偏和频偏进行恢复
%*****只需设计一个调节步长即可找到插值位置，不过要计算插值位置的整数部分。
%*****参数说明：r是接收序列，len是接收序列的长度
function Signal_Recover=phase_frequence_recover(r,len)
%环路滤波器参数
C1=0.022013;                                                      %相位控制增益 
C2=0.00024722;                                                  %频率控制增益 
Signal_Recover=zeros(len,1);                                 %锁相环锁定及稳定后的数据
NCO_Phase=zeros(len,1);                                      %锁定的相位
Discriminator_Out=zeros(len,1);
Freq_Control=zeros(len,1);
Phase_Part=zeros(len,1);                                       %锁相环相位
Freq_Part=zeros(len,1);                                         %锁相环频率
for i=2:len
    Signal_Recover(i)=r(i)*exp(-j*mod(NCO_Phase(i-1),2*pi));   %得到鉴相器的输入
    I_Recover(i)=real(Signal_Recover(i));                    %鉴相器的I路输入信息数据
    Q_Recover(i)=imag(Signal_Recover(i));                 %鉴相器的Q路输入信息数据
    Discriminator_Out(i)=(sign(I_Recover(i))*Q_Recover(i)-sign(Q_Recover(i))*I_Recover(i))...
                /(sqrt(2)*abs(Signal_Recover(i)));             %鉴相器的输出，判决
    Phase_Part(i)=Discriminator_Out(i)*C1;               %环路滤波器处理
    Freq_Control(i)=Phase_Part(i)+Freq_Part(i-1);
    Freq_Part(i)=Discriminator_Out(i)*C2+Freq_Part(i-1);
    NCO_Phase(i)=NCO_Phase(i-1)+Freq_Control(i);  %进行相位调整
end

