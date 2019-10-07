% gen  AM signal
function [rxSignal,signal_new] = gen_AM(signal)
j=sqrt(-1);
signal_new=signal;
m_a=signal.am.m_a;
fs=signal.am.fs;
IFfs=signal.am.IFfs;
fc=signal.am.fc;
fc_amp=signal.am.fc_amp;
f_offset=signal.am.f_offset;
LOphaseTemp=signal.am.LOphaseTemp;
LOphaseTemp_ddc=signal.am.LOphaseTemp_ddc;
in_sig_amp=signal.am.in_sig_amp;
in_sig_f0=signal.am.in_sig_f0;
in_sig_phase=signal.am.in_sig_phase;
lpf_lowf_stop=signal.am.lpf_lowf_stop;
%buffer
Ifrebuffer=signal.am.Ifrebuffer;
ddcrebuffer=signal.am.ddcrebuffer;
ddcconvbuffer=signal.am.ddcconvbuffer;
len=signal.am.len;
%% BaseBand mod
t=(0:len-1)/fs;
% baseband signal
x=m_a*in_sig_amp.'.*sin(2*pi*in_sig_f0.'.*t+in_sig_phase.');
x=sum(x,1);
signal_new.srcdata=x;
%normalization
x=x/sum(in_sig_amp);
signal_new.am.in_sig_phase=2*pi*in_sig_f0.*(t(end)+t(2))+in_sig_phase;
if signal.gen_method=="Baseband"
    % freq offset +phase offset
    rxSignal=x.*cos(2*pi*f_offset*t+LOphaseTemp)-x.*sin(2*pi*f_offset*t+LOphaseTemp)*j;
    signal_new.am.LOphaseTemp=LOphaseTemp+2*pi*f_offset*(t(end)+t(2));
    % add noise
    rxSignal=awgn(rxSignal,signal.noise,'measured');
    return
end
% use phase message to gen ssb
if signal.type=="USB"||signal.type=="LSB"
   x=m_a*in_sig_amp.'.*exp(j*(2*pi*in_sig_f0.'.*t+in_sig_phase.'));
   x=sum(x,1); 
   x=x/sum(in_sig_amp);
end
%% IF mod
if signal.gen_method=="IF"||signal.gen_method=="IF2Base"
    %resample
    rebufferlen2=10;
    rebufferlen=round(rebufferlen2*IFfs/fs);
    x= [Ifrebuffer,x];
    signal_new.am.Ifrebuffer=x(end-2*rebufferlen2+1:end);
    xIF=resample(x,IFfs,fs);
    xIF=xIF(rebufferlen+1:end-rebufferlen);

     % mod
     if signal.type=="AM"
         txSignalIF = ammod(xIF,fc,IFfs,LOphaseTemp,fc_amp);
     end
     t=(0:length(xIF)-1)/IFfs;
     if signal.type=="USB"
        % txSignalIF = ssbmod(xIF,fc,IFfs,LOphaseTemp,'upper'); %cannot package continue
         txSignalIF=real((xIF).*exp(j*2*pi*fc*t+j*LOphaseTemp));
     end
     if signal.type=="LSB"
%         txSignalIF = ssbmod(xIF,fc,IFfs,LOphaseTemp);
          txSignalIF=real((xIF).*exp(-j*2*pi*fc*t-j*LOphaseTemp));
     end
    
    signal_new.am.LOphaseTemp=LOphaseTemp+2*pi*fc/IFfs*(length(xIF)+0);
    rxSignal=awgn(txSignalIF,signal.noise,'measured');
    if signal.gen_method=="IF"
        return
    end
end
%% IF2Base mod
if signal.gen_method=="IF2Base"
    %% DDC
    %LPF
	lpf_ddc = fir1(64,lpf_lowf_stop,'low');
    txSignalIF=rxSignal;
	txlen=length(txSignalIF);
	t=(0:txlen-1)/IFfs;
	xc_ddc=cos(2*pi*(fc+f_offset)*t+LOphaseTemp_ddc);
	xs_ddc=-sin(2*pi*(fc+f_offset)*t+LOphaseTemp_ddc);
 	signal_new.am.LOphaseTemp_ddc=mod(2*pi*(fc+f_offset)/IFfs*(txlen)+LOphaseTemp_ddc,2*pi);
	IfToBaseI=xc_ddc.*txSignalIF;
	IfToBaseQ=xs_ddc.*txSignalIF;
   % freqz(lpf_ddc)
   % LPF
    IfSignal=IfToBaseI+IfToBaseQ*j;
    IfSignal=[ddcconvbuffer,IfSignal];
    [IfSignal,xend]=Conv2(lpf_ddc,IfSignal);
    signal_new.am.ddcconvbuffer=xend;
    rxSignal= IfSignal;
    % resample
    rebufferlen2=10;
    rebufferlen=round(rebufferlen2*IFfs/fs);
    
    rxSignal= [ddcrebuffer,rxSignal];
    signal_new.am.ddcrebuffer=rxSignal(end-2*rebufferlen+1:end);
    rxSignal=resample(rxSignal,fs,IFfs);
    rxSignal=rxSignal(rebufferlen2+1:end-rebufferlen2);
end

end

function [y,xend]=Conv2(h,x)
    hlen=length(h);
    y=conv(h,x);
    y=y(hlen:end-hlen+1);
    xend=x(end-hlen+2:end);
end