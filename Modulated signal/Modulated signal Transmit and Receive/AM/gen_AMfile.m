function gen_AMfile(signal,rxSignal,dataform,datatype)
%% gen filename 
if signal.type=="AM"
    filename=[str2mat(signal.type),'_',num2str(signal.gen_method),'_ma',num2str(signal.am.m_a),'_fs',num2str(signal.am.fs),'_IFfs',num2str(signal.am.IFfs),'_fc',num2str(signal.am.fc), ...
        '_Foffset',num2str(signal.am.f_offset),'_SNR',num2str(signal.noise),dataform];
    filename2=[str2mat(signal.type),'_',num2str(signal.gen_method),'_ma',num2str(signal.am.m_a),'_fs',num2str(signal.am.fs),'_IFfs',num2str(signal.am.IFfs),'_fc',num2str(signal.am.fc), ...
        '_Foffset',num2str(signal.am.f_offset),'_SNR',num2str(signal.noise),'_SRCdata',dataform];
else
    disp('error');
end
%% write file
fileID = fopen(filename,'w');
if signal.gen_method=="Baseband" 
    tmp= -1;
end
if signal.gen_method=="IF" 
    tmp=-2;
end
if signal.gen_method=="IF2Base" 
    tmp=-3;
end
signal_para=[1,tmp,signal.am.m_a,signal.am.fs,signal.am.IFfs,signal.am.fc,signal.am.fc_amp,signal.am.f_offset,...
    length(signal.am.in_sig_amp),signal.am.in_sig_amp,signal.am.in_sig_f0,signal.am.in_sig_phase,signal.noise,123456];
if signal.gen_method=="Baseband"||signal.type=="IF2Base" % IQ signal
    %% data:[parameter,IQdata];2*N dim
    signal_para=[signal_para;zeros(1,length(signal_para))];
    fwrite(fileID,signal_para,datatype);
    I=real(rxSignal);
    Q=imag(rxSignal);
    fwrite(fileID,[I;Q],datatype);
end
if signal.gen_method=="IF"
    %% data :[parameter,IF data];,1*N  dim
    fwrite(fileID,signal_para,datatype);
    fwrite(fileID,rxSignal,datatype); 
end
fclose(fileID);
fileID = fopen(filename2,'w');
fwrite(fileID,signal.srcdata,datatype); 
end

