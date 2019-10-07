function gen_file(signal,rxSignal,dataform)

if signal.type=="USB"||signal.type=="LSB"
    filename=[str2mat(signal.type),'_',num2str(signal.am.m_a),'_',num2str(signal.am.fs),'_',num2str(signal.am.IFfs),'_',num2str(signal.am.fc), ...
        '_',num2str(signal.am.fc_amp),'_',num2str(signal.am.f_offset),'_',num2str(signal.am.in_sig_amp),'_',num2str(signal.am.in_sig_f0), ...
        '_',num2str(signal.am.in_sig_phase),'_',num2str(signal.noise),dataform];
end






end