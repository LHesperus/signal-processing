function [x] = fourTOtwo(bits)
% 实现4电平向2电平转换，用作16QAM  
x=zeros(2,length(bits));
for i=1:length(bits)
    if bits(i)==3
        x(1,i)=1;x(2,i)=1;
    elseif bits(i)==1
        x(1,i)=1;x(2,i)=-1;
    elseif bits(i)==-1
        x(1,i)=-1;x(2,i)=-1;     
    else
        x(1,i)=-1;x(2,i)=1;   
    end
end
x=reshape(x,1,2*length(x));