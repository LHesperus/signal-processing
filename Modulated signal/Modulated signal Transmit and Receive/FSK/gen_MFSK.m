% gen MQAM signal
%
function [rxSignal,signal_new]= gen_MFSK(signal)
j=sqrt(-1);
signal_new=signal;
M=signal.M;
k=log2(M);                   % Number of bits per symbol
n=signal.symlen*k;
f_offset=signal.f_offset;
p_offset=signal.p_offset;
fs=signal.fs;
fb=signal.fb;
fc=signal.fc;
freq_sep=signal.freq_sep;
IFfs=signal.IFfs;
lpf_lowf_stop=signal.lpf_lowf_stop;

rolloff=signal.rolloff;
span=signal.span;
sps=signal.sps;
%buf
LOphaseTemp=signal.LOphaseTemp;
LOphaseTemp_ddc=signal.LOphaseTemp_ddc;
baseconvbuf=signal.baseconvbuf;
ddcconvbuf=signal.ddcconvbuf;
baserebuf=signal.baserebuf;
Ifrebuf=signal.Ifrebuf;
ddcrebuf=signal.ddcrebuf;
encodeType=signal.encodeType;
%init
state=signal.state;

%% gen IQ 
if signal.bindataType=="Random"
    dataBin=randi([0 1],n,1);                             % Generate vector of binary data
end
if signal.bindataType=="External"
    dataBin=signal.dataBin;
    if mod(length(dataBin),k)~=0
        disp('外部导入的二进制长度应该为log2(M)的整数倍');
        return
    end
end
dataInMatrix = reshape(dataBin,length(dataBin)/k,k);  % Reshape data into binary k-tuples, k = log2(M)
dataSymbolsIn = bi2de(dataInMatrix);                  % Convert to integers

if encodeType=="Gray"
%     databin=dec2bin(dataSymbolsIn,k)-48;
%     databin=reshape(databin,1,[]);
    dataMod=bingray(dataSymbolsIn,'fsk',M);
end
if encodeType=="bin"
%     databin=dataBin;
    dataMod=dataSymbolsIn;
end
dataMbin=zeros(M,length(dataMod));
for ii=1:M
    dataMbin(ii,:)=(dataMod==ii-1);
end

%% Base Band
%% filter and resample (gen baseband signal)
rrcFilter = rcosdesign(rolloff, span, sps,'sqrt');
txSignal=zeros(M,length(dataMbin)*sps);
for ii=1:M
    txSignal(ii,1:sps:end)=dataMbin(ii,:);
end
if state=="Init"
    baseconvbuf=zeros(M,length(rrcFilter)-1);
    signal_new.baseconvbuf=baseconvbuf;
end
for ii=1:M
    % shape-conv
    Temp=[baseconvbuf(ii,:),txSignal(ii,:)]; 
    [Temp,xend]=Conv2(rrcFilter,Temp);
    txSignal(ii,:)=Temp;
    signal_new.baseconvbuf(ii,:)=xend;
end
 %resample
rebufferlen2=20;
rebufferlen=round(rebufferlen2*fs/(sps*fb));
if state=="Init"
    baserebuf=zeros(M,2*rebufferlen2);
    signal_new.baserebuf=baserebuf;
end
%txSignalTemp=zeros(M,1);
for ii=1:M
    Temp= [baserebuf(ii,:),txSignal(ii,:)];
    signal_new.baserebuf(ii,:)=Temp(end-2*rebufferlen2+1:end);
    temp=resample(Temp,fs,sps*fb);   
    txSignalTemp(ii,:)=temp(rebufferlen+1:end-rebufferlen);
end
txSignal=txSignalTemp;
if signal.gen_method=="Baseband"
    txlen=size(txSignal,2);
    t=(0:txlen-1)/fs;
    if state=="Init"
        LOphaseTemp=zeros(M,1);
    end
    rxSignal=txSignal.*exp(j*(2*pi*f_offset*t+LOphaseTemp)+j*p_offset);
    signal_new.LOphaseTemp=mod(2*pi*f_offset*(t(end)+t(2))+LOphaseTemp,2*pi);
   %% channel
    if signal.noisePowType=="SNR"
        rxSignal=awgn(rxSignal,signal.noise,'measured');
    end
    if signal.noisePowType=="EbNo"
        EbNo=signal.noise;
        snr = EbNo + 10*log10(k) - 10*log10(fs/fb);
        rxSignal=awgn(rxSignal,snr,'measured');
    end
    signal_new.state="run";
    return
end

%% gen IF signal
if signal.gen_method=="IF"||signal.gen_method=="IF2Base"
    %resample ->base to IF
   % txSignalIF=resample(txSignal,IFfs,fs);
    rebufferlen2=20;
    rebufferlen=round(rebufferlen2*IFfs/fs);
    if state=="Init"
        Ifrebuf=zeros(M,2*rebufferlen2);
        signal_new.Ifrebuf=Ifrebuf;
    end
    txSignalTemp=[];
    for ii=1:M
        Temp= [Ifrebuf(ii,:),txSignal(ii,:)];
        signal_new.Ifrebuf(ii,:)=Temp(end-2*rebufferlen2+1:end);
        Temp=resample(txSignal,IFfs,fs);
        txSignalTemp(ii,:)=Temp(rebufferlen+1:end-rebufferlen);
    end
    txSignalIF=txSignalTemp;
    txlen=size(txSignalIF,2);
    t=(0:txlen-1)/IFfs;
    fcM=fc+cumsum(ones(1,M)*freq_sep)-freq_sep;
    xcM=cos(2*pi*fcM'.*t+LOphaseTemp.');
    xsM=-sin(2*pi*fcM'.*t+LOphaseTemp.');
    signal_new.LOphaseTemp=mod(2*pi*fcM*(t(end)+t(2))+LOphaseTemp,2*pi);
 
    txSignalIF=real(txSignalIF).*xcM+imag(txSignalIF).*xsM; 
    txSignalIF=sum(txSignalIF,1);
    if signal.noisePowType=="SNR"
       rxSignal=awgn(txSignalIF,signal.noise,'measured');
    end
    if signal.noisePowType=="EbNo"
       EbNo=signal.noise;
       snr = EbNo + 10*log10(k) - 10*log10(IFfs/fb);%这里应该是fs，还是IFfs?
       rxSignal=awgn(txSignalIF,snr,'measured');
    end
    if signal.gen_method=="IF"
        signal_new.state="run";
        return
    end
end



if signal.gen_method=="IF2Base"
	%% DDC
	txSignalIF=rxSignal;
	txlen=length(txSignalIF);
	t=(0:txlen-1)/IFfs;
    fc=sum(fcM)/M;
	xc_ddc=cos(2*pi*(fc+f_offset)*t+LOphaseTemp_ddc+p_offset);
	xs_ddc=-sin(2*pi*(fc+f_offset)*t+LOphaseTemp_ddc+p_offset);
    signal_new.LOphaseTemp_ddc=mod(2*pi*(fc+f_offset)*(t(end)+t(2))+LOphaseTemp_ddc,2*pi);
	IfToBaseI=xc_ddc.*txSignalIF;
	IfToBaseQ=xs_ddc.*txSignalIF;
	%LPF
	lpf_ddc = fir1(64,lpf_lowf_stop,'low');
    lpf_ddc=1;
    %freqz(lpf_ddc)
    Ifsignal=IfToBaseI+IfToBaseQ*j;
    Ifsignal=[ddcconvbuf,Ifsignal];
    [Ifsignal,xend]=Conv2(lpf_ddc,Ifsignal);
    signal_new.ddcconvbuf=xend;
    %resample ->downsample
    % 	IfToBaseQ=resample(IfToBaseQ,fs,IFfs);
    rebufferlen2=20;
    rebufferlen=round(rebufferlen2*IFfs/fs);
    Ifsignal= [ddcrebuf,Ifsignal];
    signal_new.ddcrebuf=Ifsignal(end-2*rebufferlen+1:end);
    Ifsignal=resample(Ifsignal,fs,IFfs);
    Ifsignal=Ifsignal(rebufferlen2+1:end-rebufferlen2);
    rxSignal=Ifsignal;

%     rxSignal=IfToBaseI+IfToBaseQ*j;
    signal_new.state="run";
end

end


function [y,xend]=Conv2(h,x)
    hlen=length(h);
    y=conv(h,x);
    y=y(hlen:end-hlen+1);
    xend=x(end-hlen+2:end);
end