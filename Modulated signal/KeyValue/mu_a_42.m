%归一化零中心瞬时幅度的紧致性（四阶矩），page 264,(5-291)
%程序不好使，不知道怎么回事，按书上公式做的，没检查到错误
%如果只认为公式和紧致性有关的话还不如以下代码
%mean(y_AM.^4)/(mean(y_AM.^2)^2) 
%mean(y_2ask.^4)/(mean(y_2ask.^2)^2) 
%mean(y_mask.^4)/(mean(y_mask.^2)^2)
%上述代码简单测试发现u(AM)<2,u(ask)>2,当然这种结果与书上的结果相反
function y=mu_a_42(a)
a_h=hilbert(a);   
amp_a=abs(a_h);                                        %Envelope calculation from the Hilbert transform
m_a=mean(amp_a);
%plot(amp_a)
a_n=amp_a/m_a;
a_cn=a_n-1;
%plot(a_cn)
mu_a_42=mean(a_cn.^4)/(mean(a_cn.^2)^2);
mu_a_42=mean(a.^4)/(mean(a.^2)^2);
y=mu_a_42;
end