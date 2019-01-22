%my code can't achieve modulate recognize if uses threshold in book
function modulation_recognize(s,Rs,fc,fs)
%A:analog,D:digital                                      %range             %maybe right
tA_sigma_dp=pi/6;                                        %pi/6              %
tD_sigma_dp=pi/6.5;                                      %pi/6.5-pi/2.5     %
tAD_sigma_dp=1;                                          %pi/6              % 1
tA_P_SSB=0.5;                                            %0.5-0.99          %
tA_P_VSB=0.55;                                           %0.55-0.6          %
tAD_P_SSB=0.6;                                           %0.6-0.9           %
tAD_P_VSB=1;                                             %0.5-0.7           %1
tA_sigma_ap=pi/6.5;                                      %pi/6.5-pi/2.5     %
tD_sigma_ap=pi/5.5;                                      %pi/5.5            %
tAD_sigma_ap=pi/5.5;                                     %pi/5.5            %
t_sigma_a_2psk=0.1;                                      %0.125-0.4         %0.1
t_sigma_a_4psk=0.15;                                     %0.15              %haven't test
tA_gamma_max=5.5;                                        %5.5-6             %
tD_gamma_max=4;                                          %4                 %
tAD_gamma_max=0.1;                                       %2-2.5             %0.1
tAD_mu_a_42=2.15;                                        %2.15              %
tAD_mu_f_42=2;                                           %2.03              %
tD_AD_sigma_aa=0.25;                                     %0.25              %
tD_AD_sigma_af=1.5;                                      %0.4               %1.5

a_t=1;
Ysigma_dp=sigma_dp(s,a_t,fs,fc)     
Ysigma_ap=sigma_ap(s,a_t,fs,fc)     
Ymu_f_42=mu_f_42(s,fs,Rs)           
Ymu_a_42=mu_a_42(s)                                  %not use func in book
Ysigma_a=sigma_a(s,0.2)                              %there threshold I take 0.2 by test 
Ysigma_af=sigma_af(s,a_t,fs,Rs)     
Ysigma_aa=sigma_aa(s)               
Ygamma_max=MaxSpectralDensity(s)    
YP=SpectralSymmetryIndex(s,fs,fc)   

if Ysigma_dp>tAD_sigma_dp
       if abs(YP)>tAD_P_SSB
           if YP>0
               display('LSB');
           else
               display('USB');
           end
       else
           if Ysigma_ap<tAD_sigma_ap
               if Ysigma_a<t_sigma_a_2psk
                  display('2PSK');
               else
                   display('DSB');
               end
           else
               if Ygamma_max>tAD_gamma_max
                   if Ysigma_a<t_sigma_a_4psk
                       display('4PSK');
                   else
                       display('AM-FM');
                   end
               else
                   if Ymu_f_42>tAD_mu_f_42
                       if Ysigma_af>tD_AD_sigma_af       %I have changed logic
                           display('4FSK');
                       else
                           display('2FSK');
                       end
                   else
                       display('FM');
                   end
               end
           end
       end       
else
       if abs(YP)<tAD_P_VSB
           if Ymu_a_42<tAD_mu_a_42                        %I have changed logic
               display('AM');
           else
               if Ysigma_aa>tD_AD_sigma_aa                %I have changed logic
                   display('4ASK');
               else
                   display('2ASK');
               end
           end
       else
           display('VSB');
       end
end