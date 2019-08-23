%system initial************************************* 
close all; 
clear all; 
clc; 
% generate source data*************************** 
tRate=4; 
fs=800;
t=0:1/fs:100; 
f=100; 
PPM=400; 
data1=sin(2*pi*f.*t+1/12*pi); 
data=resample(data1,1e6,1e6-PPM); 
%--------2nd loop designed----------------------- 
BL=f*PPM/1e6*2; 

Tb=1/f; 
zeta=0.707; 
Go=10;
Gd=10;
k1=(BL*(4*zeta+2*Tb*BL+1))/(Go*Gd*(zeta+1/(4*zeta))^2);
k2=(4*Tb*BL^2)/(Go*Gd*(zeta+1/(4*zeta))^2);
%----------------------------------------------- 
% figure; 
% plot(data1,'b-x'); 
% hold on; 
% plot(data,'g-o'); 
% legend('ideal signal','resample signal'); 
% ylim([-1.5 1.5]); 
% title('400ppm 的采样频率偏移'); 
% grid on; 
% bit tracking begin******************************* 
k=1; 
ipos=7; 
tedp=data(3); 
tedm=data(5); 
path2=0; 
while((ipos+tRate/2+2)<length(data)-5) 
   %  step1 :estimate correct strobe vaule 
   mk=floor(ipos); 
   uk=ipos-mk; 
   uk_vec(2*k-1)=uk; 
   c_2=1/6*uk^3-1/6*uk; 
   c_1=-1/2*uk^3+1/2*uk^2+uk; 
   c_0=1/2*uk^3-uk^2-1/2*uk+1; 
      c1=-1/6*uk^3+1/2*uk^2-1/3*uk; 
   d2=data(mk+2); 
   d1=data(mk+1); 
   d0=data(mk); 
   d_1=data(mk-1); 
   iData=c_2*d2+c_1*d1+c_0*d0+c1*d_1; 
   strobe(k)=iData; 
   tedc =iData; 
   % step2: phase detect 
   gted=sign(tedp-tedc)*tedm; 
      terror=gted; 
   ted_vec(k)=terror; 
   path1=gted*k1; 
      path2=path2+k2*gted; 
   test1(k)=path1; 
   test2(k)=path2; 
   ipos=ipos+tRate/2+(path1+path2)*tRate;% get the position of tedM 
   % step3 :estimate the TedM vaule 
   mk=floor(ipos); 
   uk=ipos-mk; 
   mk_vec(k)=mk; 
   uk_vec(2*k)=uk; 
    c_2=1/6*uk^3-1/6*uk; 
   c_1=-1/2*uk^3+1/2*uk^2+uk; 
   c_0=1/2*uk^3-uk^2-1/2*uk+1; 
   c1=-1/6*uk^3+1/2*uk^2-1/3*uk; 
  d2=data(mk+2); 
   d1=data(mk+1); 
      d0=data(mk); 
   d_1=data(mk-1); 
   iData=c_2*d2+c_1*d1+c_0*d0+c1*d_1;  
   tedm=iData; 
   tedp=tedc; 
   ipos=ipos+tRate/2; 
   k=k+1; 
end 
figure; 
plot( ted_vec,'k-'); 
tit=sprintf('output of Time detector'); 
title(tit); 
figure; 
plot( uk_vec,'k-'); 
tit=sprintf('output of uk'); 
title(tit); 
disp('sample frequency error estimated');disp(path2*1e6); 
disp('real PPM=');disp(PPM); 
figure; 
plot(test1); 
hold on; 
plot(test2,'r'); 
legend('path1','path2'); 