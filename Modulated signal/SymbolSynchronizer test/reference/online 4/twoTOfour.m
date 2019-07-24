function [x] = twoTOfour(bits)
% 实现4电平，用作16QAM  
for i=1:2:length(bits)
    if bits(i)==1 & bits(i+1)==1
        x((i+1)/2)=3;
    elseif bits(i)==1 & bits(i+1)==-1
        x((i+1)/2)=1;
    elseif bits(i)==-1 & bits(i+1)==-1
        x((i+1)/2)=-1;     
    else
        x((i+1)/2)=-3;   
    end
end