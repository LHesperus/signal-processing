%File:timing_syn.m timing synchronization 
clc 
clear 
Data_Len = 2000; 
 
Fs = 3840000*8;                  % Sampling Frequency 
Fd = 3840000;                  % Symbol Frequency 
SNR = 30;                   % S/N Ratio for Chanel Simulatioin  
RolloffCoef = 0.22;         % Roll Off Coeff. 
T_Gain = 0.02;              % TED Loop Gain 
 
Ratio = Fs/Fd/2;            % = Ts/Td/2  
Offset = 32;                %  
 
timing_error = 0; 
datalen = Fs / Fd * (Data_Len - Offset); 
displaysize  = 128; 
ted_out = zeros(1,displaysize); 
Interp_Pos = 2*Ratio + Ratio; 
Rec_out = zeros(1,displaysize); 
 
disp('1 Data Send'); 
%1+++++++++++++Data Source+++++++++++++++++++ 
disp('  1.1 Data Source'); 
x = (-1).^(rand(1,Data_Len)>0.5) + j * (-1).^(rand(1,Data_Len)>0.5); 
 
figure(1) 
plot(x,'r*'); 
xlabel('real') 
ylabel('image') 
xlim([-2.0 2.0]); 
ylim([-2.0 2.0]); 
title('Sending Conset') 
grid on; 
 
%+++++++++++++pulse shaping+++++++++++++++++++ 
%        Using Rolloff Setting 
%+++++++++++++++++++++++++++++++++++++++++++++ 
disp('  1.2 Pulse Shaping'); 
x_t=rcosflt(x,Fd,Fs,'sqrt',RolloffCoef); 
 
%+++++++++++++channel simulation++++++++++++++ 
%   Add White Offsetoise Using SOffsetR Setting         
%+++++++++++++++++++++++++++++++++++++++++++++ 
disp('2 Channel Simulation'); 
c_t = awgn(x_t,SNR,'measured'); 
 
%++++++++++++++++++receive++++++++++++++++++++ 
disp('3 Receive'); 
 
%4++++++++++Matching Filter++++++++++++++++++++ 
disp('  3.1 Matching Filter'); 
%matched_data=rcosflt(r_t,Fd,Fs,'sqrt/Fs',RolloffCoef); 
r_t=rcosflt(c_t,Fd,Fs,'sqrt/Fs',RolloffCoef); 
matched_data=[r_t(Offset+1:end-Offset)]; 
 
%++++++++++++Timing Recovery+++++++++++++++++++ 
% =======Gardner Timing Recovery===============  
%  TE(k)={Y[(k-1)Td]-Y[kTd])*Y[(kTd-Td/2] 
% =======Parabolic Interpolation===============  
%     C_2 =  0.5 * mu^2 - 0.5 * mu; 
%     C_1 = -0.5 * mu^2 + ( 0.5 + 1 ) * mu; 
%     C0  = -0.5 * mu^2 + ( 0.5 - 1 ) * mu + 1; 
%     C1  =  0.5 * mu^2 - 0.5 * mu; 
%+++++++++++++++++++++++++++++++++++++++++++++++ 
disp('  3.2 Timing Recovery'); 
C_2 = inline('0.5*u^2-0.5*u'); 
C_1 = inline('-0.5*u^2+1.5*u'); 
C0  = inline('-0.5*u^2-0.5*u+1'); 
C1  = inline('0.5*u^2-0.5*u'); 
 
ted_data1 = matched_data(Offset); 
ted_data2 = matched_data(Offset+Ratio); 
 
% hp = timing_prefilter(T,Ti,2,beta); 
k = 1; 
count = 0; 
 
while(  Interp_Pos < ( datalen - 6 ) ) 
    %++++++++++++The first half++++++++++++++++++ 
    mk = floor(Interp_Pos);         % Integer Part 
    uk = Interp_Pos-mk;             % Fraction Part 
     
    C_2u = C_2(uk); 
    C_1u = C_1(uk); 
    C0u  = C0(uk); 
    C1u  = C1(uk); 
     
    %+++++++++++++++Get Sampling Data+++++++++++++ 
%     data1 = matched_data(mk); 
%     data2 = matched_data(mk+1); 
%     data3 = matched_data(mk+2); 
%     data4 = matched_data(mk+3); 
     
    data1 = matched_data(mk-1); 
    data2 = matched_data(mk); 
    data3 = matched_data(mk+1); 
    data4 = matched_data(mk+2); 
     
    %+++++++++++++Interpolation+++++++++++++++++++ 
    % out = C_2 * in_i(4) + C_1 * in_i(3) + C0 * in_i(2) + C1 * in_i(1); 
    %+++++++++++++++++++++++++++++++++++++++++++++ 
    Interp_data = C_2u * data4 + C_1u * data3 + C0u * data2 + C1u * data1; 
    Rec_out(k) = Interp_data; 
    ted_data3 = Interp_data; 
 
    Interp_Pos = Interp_Pos + Ratio + timing_error;%  
       
    %++++++++++++++Gardner TED+++++++++++++++++++ 
    % temp= ( ted_data1 - ted_data3 ) * ted_data2; 
    %++++++++++++++++++++++++++++++++++++++++++++ 
    temp = ( ted_data1 - ted_data3 ) * conj(ted_data2); 
 
    %++++++++++++++Loop Filter++++++++++++++++++ 
    timing_error = real(temp) * T_Gain; 
    %timing_error = timing_error + real(temp) * T_Gain; 
     
    ted_out(k) = timing_error; 
   
    %+++++++++++++The second half+++++++++++++++ 
    mk = floor(Interp_Pos); 
    uk = Interp_Pos-mk 
     
    C_2u = C_2(uk); 
    C_1u = C_1(uk); 
    C0u  = C0(uk); 
    C1u  = C1(uk); 
     
    %+++++++++++++++Get Sampling Data++++++++++++++ 
%     data1 = matched_data(mk); 
%     data2 = matched_data(mk+1); 
%     data3 = matched_data(mk+2); 
%     data4 = matched_data(mk+3); 
     
    data1 = matched_data(mk-1); 
    data2 = matched_data(mk); 
    data3 = matched_data(mk+1); 
    data4 = matched_data(mk+2); 
    %+++++++++++++++++++Interpolation++++++++++++++ 
    % out = C_2 * in_i(4) + C_1 * in_i(3) + C0 * in_i(2) + C1 * in_i(1); 
    %++++++++++++++++++++++++++++++++++++++++++++++ 
    Interp_data = C_2u * data4 + C_1u * data3 + C0u * data2 + C1u * data1; 
  
    %+++Update Sampling Position(NCO Process)++++ 
    %  NewPosition = OldPosition + Fs/Fd/2 + TED  
    %++++++++++++++++++++++++++++++++++++++++++++ 
    Interp_Pos = Interp_Pos + Ratio + timing_error; 
 
    ted_data1 = ted_data3; 
    ted_data2 = Interp_data;   
 
    k = k + 1; 
    count = count + 1; 
    if count==displaysize 
        count = 0; 
        k = 1; 
        figure(2); 
        plot(Rec_out,'r*'); 
        xlabel('real') 
        ylabel('image') 
        xlim([-2.0 2.0]); 
        ylim([-2.0 2.0]); 
        title('Receiving Conset') 
        grid on; 
 
        figure(3); 
        plot(ted_out,'r+'); 
        ylim([-0.2 0.2]); 
        title('TED Error') 
        grid on; 
        pause(0.1); 
    end 
end 
figure(3); 
stem(Rec_out); 
grid; 