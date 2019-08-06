%% Symbol synchronization by Gardner algorithm
% IQ_in:输入的未定时的IQ信号，输入信号每个符号有4个采样点
% 参考资料：
%[1] A BPSK/QPSK Timing-Error Detector for Sampled Receivers
%[2] Interpolation in Digital Modems-Part I: Fundamentals
%[3] Interpolation in Digital Modems-Part II:Implementation and Performance
% w : NCO control word
% q : NCO register contents 
% m : mth clock tick
% u : fraction interval

function IQ_out=sym_synch_Gardner(IQ_in)
j=sqrt(-1);
%归一化
II_m=real(IQ_in)/max(real(IQ_in));
QQ_m=imag(IQ_in)/(max(imag(IQ_in)));
% 定时
datalength=length(II_m)+1;
w=[0.5,zeros(1,round(datalength/4)-1)];
q=[0.9,zeros(1,datalength-1)];
q_temp=[q(1),zeros(1,datalength-1)];
u=[0.6,zeros(1,round(datalength/2)-1)];
m=1; 
s=1;
k=1; 
strobe=zeros(1,datalength);
time_error=zeros(1,round(datalength/4));
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
IQ_out=yi_II+yi_QQ*j;
figure;plot(w)
figure;plot(time_error)

[C_02;C_01;C_0;C_1]
q(1:5)'
w(1:5)'
q_temp(1:5)'
u(1:5)'
end