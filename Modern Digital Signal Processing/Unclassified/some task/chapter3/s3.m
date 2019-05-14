clear all
close all
j=sqrt(-1);
L=10;  %time of sim
N=2^8; %length of  signal
M=64;   %max delay
n=0:N-1;
f=[0.15,0.17,0.26];

for ii=1:L
	phi_k=2*pi*rand(1,3);             %phase [0 2pi]
	a=rand(1,3);
    a=[2 2 3];
	a_k=a.*exp(j*phi_k);       %|a_k|?
    
	s_1=a_k(1)*exp(j*2*pi*f(1)*n);
	s_2=a_k(2)*exp(j*2*pi*f(2)*n);
	s_3=a_k(3)*exp(j*2*pi*f(3)*n);
	s_n=[s_1;s_2;s_3];
	v_1=awgn(s_1,20,'measured');
	v_2=awgn(s_2,25,'measured');
	v_3=awgn(s_3,30,'measured');
	v=[v_1;v_2;v_3];
	u=sum(s_n+v);     %signal 
	
	
	%r_1(m)=1/N*\sum{n=0}{N-1}u_N(n)*u_N_*(n-m)  |m|<=N-1
	
	m=-M+1:M-1;        %delay of two signal
	%figure
	%r_1=conv(u,u)/N;
		%r_1=zeros(1,size(m));
	r_1_m=0;
	for mm=1:size(m,2);
		if m(mm)>=0 
		for nn=m(mm)+1:N
			%r_1_m=r_1_m+conj(u(nn))*u(nn-m(mm));
            r_1_m=r_1_m+u(nn)*conj(u(nn-m(mm)));
		end
		else
		for nn=1:N+m(mm);
			r_1_m=r_1_m+u(nn)*conj(u(nn-m(mm)));
		end
		end
	
		r_1(mm)=r_1_m/N;
		r_1_m=0;
        
    end
    %figure
%	r_1=r_1(m(1)+N:m(end)+N)/max(r_1);
%    plot(abs(fft(r_1)))
r_1=r_1/max(r_1);
w_len=100;
for w=1:w_len
    S_BT(w) = sum(r_1.*exp(-j*2*pi*((w-w_len/2)/w_len).*m(1:end)));
end
S_BT=abs(S_BT)/max(abs(S_BT));
%figure
%plot(-0.5:1/w_len:0.5-1/w_len,log10(S_BT))
%title('BT')

[peak_value,peak_pos]=findpeaks(log10(S_BT));
f1_pos=find(peak_value==max(peak_value));
peak_value(f1_pos)=-100;
f2_pos=find(peak_value==max(peak_value));
peak_value(f2_pos)=-100;
f3_pos=find(peak_value==max(peak_value));
f_est=[peak_pos(f1_pos),peak_pos(f2_pos),peak_pos(f3_pos)];
f_est=f_est*(1/w_len)-0.5;
f_est=sort(f_est)
e1=f_est-f;


L1=(N-M/2)/(M/2);

for w=1:w_len
    for ii=1:L1
       S_per(ii,w) = abs(sum(u((ii-1)/2*M+1:(ii+1)/2*M).*exp(-j*2*pi*((w-w_len/2)/w_len).*(0:M-1)))).^2;
    end  
end
S_per=S_per/M;
S_per=sum(S_per)/L1;
S_per=S_per/max(S_per);
%figure
%plot(-0.5:1/w_len:0.5-1/w_len,log10(S_per))
%title('Welch')

[peak_value,peak_pos]=findpeaks(log10(S_per));
f1_pos=find(peak_value==max(peak_value));
peak_value(f1_pos)=-100;
f2_pos=find(peak_value==max(peak_value));
peak_value(f2_pos)=-100;
f3_pos=find(peak_value==max(peak_value));
f_est=[peak_pos(f1_pos),peak_pos(f2_pos),peak_pos(f3_pos)];
f_est=f_est*(1/w_len)-0.5;
f_est=sort(f_est);
e2=f_est-f;
end
e(1,:)=sum(abs(e1).^2)/L;
e(2,:)=sum(abs(e2).^2)/L;

