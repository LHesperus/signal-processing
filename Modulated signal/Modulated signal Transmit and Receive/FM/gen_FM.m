% 
function [rxSignal,signal_new]= gen_FM(signal)
j=sqrt(-1);
signal_new=signal;
fs=signal.fm.fs;
IFfs=signal.fm.IFfs;
fc=signal.fm.fc;
fDev =signal.fm.fDev ;
f_offset=signal.fm.f_offset;
LOphaseTemp=signal.fm.LOphaseTemp;
LOphaseTemp_ddc=signal.fm.LOphaseTemp_ddc;
in_sig_amp=signal.fm.in_sig_amp;
in_sig_f0=signal.fm.in_sig_f0;
in_sig_phase=signal.fm.in_sig_phase;
lpf_lowf_stop=signal.fm.lpf_lowf_stop;
%buffer
Ifrebuffer=signal.fm.Ifrebuffer;
ddcrebuffer=signal.fm.ddcrebuffer;
ddcconvbuffer=signal.fm.ddcconvbuffer;
len=signal.fm.len;
%% BaseBand mod
t=(0:len-1)/fs;
% baseband signal
x=in_sig_amp.'.*sin(2*pi*in_sig_f0.'.*t+in_sig_phase.');
x=sum(x,1);
%normalization
x=x/sum(in_sig_amp);
signal_new.fm.in_sig_phase=2*pi*in_sig_f0.*(t(end)+t(2))+in_sig_phase;
if signal.gen_method=="Baseband"
    % freq offset +phase offset
    rxSignal=x.*cos(2*pi*f_offset*t+LOphaseTemp)-x.*sin(2*pi*f_offset*t+LOphaseTemp)*j;
    signal_new.fm.LOphaseTemp=LOphaseTemp+2*pi*f_offset*(t(end)+t(2));
    % add noise
    rxSignal=awgn(rxSignal,signal.noise,'measured');
    return
end

%% IF mod
if signal.gen_method=="IF"||signal.gen_method=="IF2Base"
    %resample
    rebufferlen2=10;
    rebufferlen=round(rebufferlen2*IFfs/fs);
    x= [Ifrebuffer,x];
    signal_new.fm.Ifrebuffer=x(end-2*rebufferlen2+1:end);
    xIF=resample(x,IFfs,fs);
    xIF=xIF(rebufferlen+1:end-rebufferlen);
 
     % mod
    txSignalIF = fmmod(xIF,fc,IFfs,fDev,LOphaseTemp);
    tIF=(0:length(xIF)-1)/IFfs;
    px=2*pi*fDev*trapz(tIF,xIF);%signal phase
    signal_new.fm.LOphaseTemp=LOphaseTemp+2*pi*fc/IFfs*(length(xIF))+px;
    signal_new.fm.LOphaseTemp=mod(signal_new.fm.LOphaseTemp,2*pi);
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
 	signal_new.fm.LOphaseTemp_ddc=mod(2*pi*(fc+f_offset)/IFfs*(txlen)+LOphaseTemp_ddc,2*pi);
	IfToBaseI=xc_ddc.*txSignalIF;
	IfToBaseQ=xs_ddc.*txSignalIF;
   % freqz(lpf_ddc)
   % LPF
    IfSignal=IfToBaseI+IfToBaseQ*j;
    IfSignal=[ddcconvbuffer,IfSignal];
    [IfSignal,xend]=Conv2(lpf_ddc,IfSignal);
    signal_new.fm.ddcconvbuffer=xend;
    rxSignal= IfSignal;
    % resample
    rebufferlen2=10;
    rebufferlen=round(rebufferlen2*IFfs/fs);
    
    rxSignal= [ddcrebuffer,rxSignal];
    signal_new.fm.ddcrebuffer=rxSignal(end-2*rebufferlen+1:end);
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