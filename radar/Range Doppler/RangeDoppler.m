%% 距离多普勒
% s_ref:发射的信号,行向量
% s_echo:回波,行向量
% X：参考信号分块长度
% L:回波信号分块为X+L
% R_fftn,D_fftn：距离维，多普勒维fft的点数，设置为0时则按信号长度算
% fs：采样率
% type：处理方法，用于函数扩展 0-默认
function [Range,doppler,RD]=RangeDoppler(s_ref,s_echo,X,L,R_fftn,D_fftn,fs,type)
tic
c=3e8;
if size(s_ref,2)==1
    s_ref=s_ref.';
end
if size(s_echo,2)==1
    s_echo=s_echo.';
end

Dim1=floor(length(s_ref)/X);
Dim2=floor((length(s_echo)-L)/X);
Dim=min([Dim1,Dim2]);

if R_fftn<=0
    R_fftn=X+L;
end
if D_fftn<=0
    D_fftn=Dim;
end

FastTimeDim=zeros(Dim,R_fftn);
for ii=1:Dim
    refBlock=s_ref((ii-1)*X+1:ii*X);
    echoBlock=s_echo((ii-1)*X+1:ii*X+L);
    FastTimeDim(ii,:)=fft(refBlock,R_fftn).*conj(fft(echoBlock,R_fftn));
    FastTimeDim(ii,:)=(ifft(FastTimeDim(ii,:)));%不加fftshit，距离从0开始
end
SlowTimeDim=fftshift(fft(FastTimeDim,D_fftn,1),1);%加fftshift，速度从负的最小值到正的最大值
RD=SlowTimeDim;
time=toc;
%% 输出信息
disp('********************')
disp(['矩阵维数：',num2str(size(RD))])
disp(['计算耗时：',num2str(time)])
doppler=(-D_fftn/2:D_fftn/2-1)*(fs/X/D_fftn);%最大可检测多普勒为fs/(2*X),X应该>=fs*(lambda/(4Vmax))
disp(['最大可检测多普勒：',num2str(fs/(2*X))])
Range=(0:R_fftn-1)*(1/fs)*c;%采样间隔1/fs,距离为1/fs*c
disp(['最大可检测距离为：',num2str(R_fftn*c/fs)])
Range=Range(end:-1:1);
% figure
% mesh(Range,doppler,10*(abs(SlowTimeDim)))%/max(max(abs(SlowTimeDim)))
% title('距离多普勒')

end