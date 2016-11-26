clc;
clear all;
%% Ask for user input
pal = input('Enter a word to send :','s'); 
EbNo = input('Enter the SNR to be used:','s'); 
EbNo = str2double(EbNo);
Rb = input('Enter the transmission rate (bps) :','s');
Rb= str2double(Rb);

%% Source coding
nbits=8;
binary=de2bi(double(pal),nbits);
disp('     DEC                      BINARY              ')
disp([double(pal)',binary]);


rows = size (binary,1); columns=size(binary,2);
binary= reshape(binary',1,rows*columns); %Convert matrix in a row vector. 
mensaje=zeros(rows*2,7);
j=1;
%% Channel coding
for i=1:4:rows*columns
   
   a=[binary(1,i+3) binary(1,i+2) binary(1,i+1) binary(1,i)];
   b=[1 0 0 0];%polynomial x^3
   
   c=conv(a,b);
   
   g=[1 1 0 1]; %Generator polynomial G(x)
   [x,r]=deconv(c,g); %Divide into G(x)
   
   
   for d=1:7
       if mod(r(1,d),2)== 0
           r(1,d)=0;
       else
           r(1,d)=1;
       end 
   end
    
   
   salida=c+r;
   salida=salida(7:-1:1);
  
   mensaje(j,1:7)=salida(1:7);
   j=j+1;

end
disp(mensaje);
rows = size (mensaje,1); columns=size(mensaje,2);
mensaje= reshape(mensaje',1,rows*columns); %Convert matrix into row vector (1 row, row*columns)

figure(1);subplot(311);stem(mensaje,'fill','r-');grid on;xlabel(['number of bits = ',num2str(length(mensaje))]);
title(['bits to transmit = ', num2str(length(mensaje))]);ylabel('Amplitude');

R=length(mensaje); %numero de bits a transmitir
Tb=1/Rb;           %intervalo o periodo de bit
t=0:Tb:(R*Tb)-Tb; %vector tiempo, le quito un caracter porque empieza desde cero

subplot(312);stem(t,mensaje,'b--','fill','LineWidth',1.8);xlabel('time (s)');ylabel('Amplitude');
title(['Discrete signal with bit period Tb = ', num2str(Tb*10^3),'(ms)']);grid on




mensajeRZ=zeros(1,length(mensaje)*2);

x=1;
for i=1:length(mensaje)
    
    if mensaje(1,i)==1
        
       mensajeRZ(1,x)=1;
    
    elseif  mensaje(1,i)==0
        
       mensajeRZ(1,x)=-1;
            
    end 
        
    
    mensajeRZ(1,x+1)=0;
    x=x+2;
end

R=length(mensajeRZ); %numero de bits  a transmitir
fs=R*10000; %sampling frequency
Ts=(1/fs); %sampling time =1/fs
T =(1/R); %bit time
t=[0:Ts:(R*T)-Ts]; %time vector

%transmisor
data=mensajeRZ;
data1=ones(T/Ts,1)*data;
data2=data1(:);


subplot(313);plot(t,data2,'b','LineWidth',1.8);xlabel('time (s)');ylabel('Amplitude');
title(['Binary digital signal to be transmitted with bit period T = ',num2str(T*10^3),'(ms)']);grid on
%% Digital modulation
%4QAM
M=4;
k=2;
xsym =bi2de(reshape(mensaje,k,length(mensaje)/k).','left-msb');
%stem(xsym(1:20));
y = qammod(xsym,M);

ytx=y;

%% Channel
%ynoisy=awgn(ytx,EbNo,'measured');
ynoisy = awgn(ytx,EbNo);

%% Data reception

yrx=ynoisy;

%% Digital demodulation
z = qamdemod(yrx,M);
xrx=de2bi(z);
[rows,cols]=size(xrx);
menbin=zeros(1,rows*cols);
pos=0;

xrx=reshape(xrx',1,rows*cols);

for i=1:2:length(xrx)
    
    a=xrx(1,i);
    b=xrx(1,i+1);
    
    xrx(1,i)=b;
    xrx(1,i+1)=a;
    
end


h=scatterplot(ytx);
hold on;
scatterplot(yrx);
hold off; grid on;


%% Channel decoding
for i=1:7:length(xrx)
    
    a=[xrx(1,i+6) xrx(1,i+5) xrx(1,i+4) xrx(1,i+3) xrx(1,i+2) xrx(1,i+1) xrx(1,i)];
    g=[1 1 0 1];
    
    [x,r]=deconv(a,g);
   
    
    for d=1:7
       if mod(r(1,d),2)== 0
           r(1,d)=0;
       else
           r(1,d)=1;
       end 
    end
    
    
    if(r~=0)
        if((r(1,0)==0)&&(r(1,1)==0)&&(r(1,2)==0)&&(r(1,3)==0)&&(r(1,4)==0)&&(r(1,5)==0)&&(r(1,6)==0)&&(r(1,7)==1))
            
            if(xrx(1,i)==1)
                xrx(1,i)=0;
            else
                 xrx(1,i)=1;
            end
            
        elseif ((r(1,0)==0)&&(r(1,1)==0)&&(r(1,2)==0)&&(r(1,3)==0)&&(r(1,4)==0)&&(r(1,5)==0)&&(r(1,6)==1)&&(r(1,7)==0))
            if(xrx(1,i+1)==1)
                xrx(1,i+1)=0;
            else
                 xrx(1,i+1)=1;
            end
        elseif ((r(1,0)==0)&&(r(1,1)==0)&&(r(1,2)==0)&&(r(1,3)==0)&&(r(1,4)==0)&&(r(1,5)==1)&&(r(1,6)==0)&&(r(1,7)==0))
            if(xrx(1,i+2)==1)
                xrx(1,i+2)=0;
            else
                 xrx(1,i+2)=1;
            end
        elseif ((r(1,0)==0)&&(r(1,1)==0)&&(r(1,2)==0)&&(r(1,3)==0)&&(r(1,4)==0)&&(r(1,5)==0)&&(r(1,6)==1)&&(r(1,7)==1))
            if(xrx(1,i+3)==1)
                xrx(1,i+3)=0;
            else
                 xrx(1,i+3)=1;
            end
        elseif ((r(1,0)==0)&&(r(1,1)==0)&&(r(1,2)==0)&&(r(1,3)==0)&&(r(1,4)==0)&&(r(1,5)==1)&&(r(1,6)==0)&&(r(1,7)==1))
            if(xrx(1,i+4)==1)
                xrx(1,i+4)=0;
            else
                 xrx(1,i+4)=1;
            end
        elseif ((r(1,0)==0)&&(r(1,1)==0)&&(r(1,2)==0)&&(r(1,3)==0)&&(r(1,4)==0)&&(r(1,5)==1)&&(r(1,6)==1)&&(r(1,7)==1))
            if(xrx(1,i+5)==1)
                xrx(1,i+5)=0;
            else
                 xrx(1,i+5)=1;
            end
        elseif ((r(1,0)==0)&&(r(1,1)==0)&&(r(1,2)==0)&&(r(1,3)==0)&&(r(1,4)==0)&&(r(1,5)==1)&&(r(1,6)==1)&&(r(1,7)==0))
            if(xrx(1,i+6)==1)
                xrx(1,i+6)=0;
            else
                 xrx(1,i+6)=1;
            end
        else
            disp('error no corregible');
            
        end
        
        
    end 
    
end 

ascii=zeros((length(xrx)/7)/2,8);

posi=1;
for i=1:14:length(xrx)
    
    ascii(posi,1)=xrx(1,i+3);
    ascii(posi,2)=xrx(1,i+4);
    ascii(posi,3)=xrx(1,i+5);
    ascii(posi,4)=xrx(1,i+6);
    ascii(posi,5)=xrx(1,i+10);
    ascii(posi,6)=xrx(1,i+11);
    ascii(posi,7)=xrx(1,i+12);
    ascii(posi,8)=xrx(1,i+13);
    
    posi=posi+1;
    
end
%% Source decoding
deci=bi2de(ascii);

disp(deci);

a=[char(deci)];
a=a.';
disp(a);
