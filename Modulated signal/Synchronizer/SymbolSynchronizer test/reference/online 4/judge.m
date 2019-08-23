function [x] = judge(bits)
% 实现16QAM中四电平判决 
for i=1:length(bits)
    if bits(i)>=0.5
        x(i)=3;
    elseif bits(i)<0.5 & bits(i)>=0
        x(i)=1;
    elseif bits(i)<0 & bits(i)>=-0.5
        x(i)=-1;     
    else
        x(i)=-3;   
    end
end