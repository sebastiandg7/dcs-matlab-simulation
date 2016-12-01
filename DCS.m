clc;
clear all;
pal = input('digite una palabra :','s'); 
EbNo = input('digite la relacion señal a ruido:','s'); 
EbNo = str2double(EbNo);
Rb = input('digite la tasa de tx:','s');
Rb= str2double(Rb);

nbits=8;
binary=de2bi(double(pal),nbits);
disp('     DEC                      BINARY              ')
disp([double(pal)',binary]);

rows = size (binary,1); columns=size(binary,2);
binary= reshape(binary',1,rows*columns); %convierte la matriz en un vector fila 
mensaje=zeros(rows*2,7);
j=1;
for i=1:4:rows*columns
   
   a=[binary(1,i+3) binary(1,i+2) binary(1,i+1) binary(1,i)];
   b=[1 0 0 0];%polinomio x^3
   
   c=conv(a,b);
   
   g=[1 1 0 1]; %polinomio generadorº
   [x,r]=deconv(c,g); %division entre el generador
   
   
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
mensaje= reshape(mensaje',1,rows*columns); %convierte la matriz en un vector fila (1 row, row*columns)
transmitidos=mensaje;
largo=length(mensaje);
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

%4QAM
M=4;
k=2;
xsym =bi2de(reshape(mensaje,k,length(mensaje)/k).','left-msb');
%stem(xsym(1:20));
y = qammod(xsym,M);

ytx=y;

%ynoisy=awgn(ytx,EbNo,'measured');
ynoisy = awgn(ytx,EbNo);
yrx=ynoisy;

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

contador=0;
for i=1:length(xrx)
    
    if(xrx(1,i)~=transmitidos(1,i))
        contador=contador+1;
    end
    
end

%pasando los bits a palabras



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

deci=bi2de(ascii);

disp(deci);

a=[char(deci)];
a=a.';
disp(a);

%ber medido

disp(contador/largo);


