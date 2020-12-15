web browser http://www.ilovematlab.cn/thread-60056-1-1.html
%% ��ջ�������
clc
clear

%% ѵ������Ԥ��������ȡ����һ��

%�������������ź�
load data1 c1
load data2 c2
load data3 c3
load data4 c4

%�ĸ������źž���ϳ�һ������
data(1:500,:)=c1(1:500,:);
data(501:1000,:)=c2(1:500,:);
data(1001:1500,:)=c3(1:500,:);
data(1501:2000,:)=c4(1:500,:);

%��1��2000���������
k=rand(1,2000);
[m,n]=sort(k);

%�����������
input=data(:,2:25);
output1 =data(:,1);

%�������1ά���4ά
for i=1:2000
    switch output1(i)
        case 1
            output(i,:)=[1 0 0 0];
        case 2
            output(i,:)=[0 1 0 0];
        case 3
            output(i,:)=[0 0 1 0];
        case 4
            output(i,:)=[0 0 0 1];
    end
end

%�����ȡ1500������Ϊѵ��������500������ΪԤ������
input_train=input(n(1:1500),:)';
output_train=output(n(1:1500),:)';
input_test=input(n(1501:2000),:)';
output_test=output(n(1501:2000),:)';

%�������ݹ�һ��
[inputn,inputps]=mapminmax(input_train);

%% ����ṹ��ʼ��
innum=24;
midnum=25;
outnum=4;
 

%Ȩֵ��ʼ��
w1=rands(midnum,innum);
b1=rands(midnum,1);
w2=rands(midnum,outnum);
b2=rands(outnum,1);

w2_1=w2;w2_2=w2_1;
w1_1=w1;w1_2=w1_1;
b1_1=b1;b1_2=b1_1;
b2_1=b2;b2_2=b2_1;

%ѧϰ��
xite=0.1
alfa=0.01;

%% ����ѵ��
for ii=1:10
    E(ii)=0;
    for i=1:1:1500
       %% ����Ԥ����� 
        x=inputn(:,i);
        % ���������
        for j=1:1:midnum
            I(j)=inputn(:,i)'*w1(j,:)'+b1(j);
            Iout(j)=1/(1+exp(-I(j)));
        end
        % ��������
        yn=w2'*Iout'+b2;
        
       %% Ȩֵ��ֵ����
        %�������
        e=output_train(:,i)-yn;     
        E(ii)=E(ii)+sum(abs(e));
        
        %����Ȩֵ�仯��
        dw2=e*Iout;
        db2=e';
        
        for j=1:1:midnum
            S=1/(1+exp(-I(j)));
            FI(j)=S*(1-S);
        end      
        for k=1:1:innum
            for j=1:1:midnum
                dw1(k,j)=FI(j)*x(k)*(e(1)*w2(j,1)+e(2)*w2(j,2)+e(3)*w2(j,3)+e(4)*w2(j,4));
                db1(j)=FI(j)*(e(1)*w2(j,1)+e(2)*w2(j,2)+e(3)*w2(j,3)+e(4)*w2(j,4));
            end
        end
           
        w1=w1_1+xite*dw1'+alfa*(w1_1-w1_2);
        b1=b1_1+xite*db1'+alfa*(b1_1-b1_2);
        w2=w2_1+xite*dw2'+alfa*(w2_1-w2_2);
        b2=b2_1+xite*db2'+alfa*(b2_1-b2_2);
        
        w1_2=w1_1;w1_1=w1;
        w2_2=w2_1;w2_1=w2;
        b1_2=b1_1;b1_1=b1;
        b2_2=b2_1;b2_1=b2;
    end
end
 

%% ���������źŷ���
inputn_test=mapminmax('apply',input_test,inputps);

for ii=1:1
    for i=1:500%1500
        %���������
        for j=1:1:midnum
            I(j)=inputn_test(:,i)'*w1(j,:)'+b1(j);
            Iout(j)=1/(1+exp(-I(j)));
        end
        
        fore(:,i)=w2'*Iout'+b2;
    end
end



%% �������
%������������ҳ�������������
for i=1:500
    output_fore(i)=find(fore(:,i)==max(fore(:,i)));
end

%BP����Ԥ�����
error=output_fore-output1(n(1501:2000))';



%����Ԥ�����������ʵ����������ķ���ͼ
figure(1)
plot(output_fore,'r')
hold on
plot(output1(n(1501:2000))','b')
legend('Ԥ���������','ʵ���������')

%�������ͼ
figure(2)
plot(error)
title('BP����������','fontsize',12)
xlabel('�����ź�','fontsize',12)
ylabel('�������','fontsize',12)

%print -dtiff -r600 1-4

k=zeros(1,4);  
%�ҳ��жϴ���ķ���������һ��
for i=1:500
    if error(i)~=0
        [b,c]=max(output_test(:,i));
        switch c
            case 1 
                k(1)=k(1)+1;
            case 2 
                k(2)=k(2)+1;
            case 3 
                k(3)=k(3)+1;
            case 4 
                k(4)=k(4)+1;
        end
    end
end

%�ҳ�ÿ��ĸ����
kk=zeros(1,4);
for i=1:500
    [b,c]=max(output_test(:,i));
    switch c
        case 1
            kk(1)=kk(1)+1;
        case 2
            kk(2)=kk(2)+1;
        case 3
            kk(3)=kk(3)+1;
        case 4
            kk(4)=kk(4)+1;
    end
end

%��ȷ��
rightridio=(kk-k)./kk
web browser http://www.ilovematlab.cn/thread-60056-1-1.html