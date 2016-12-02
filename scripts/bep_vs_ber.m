function[] = bep_vs_bep(mensaje)

SNR_DB=0:2:10;
snr= 10.^(SNR_DB/10);

M = 4; % Alphabet size
EbN0_min=0;EbN0_max=10;step=0.5;
SNR=[];SER=[];
for EbN0 = EbN0_min:step:EbN0_max
SNR_dB=EbN0 + 3; %for QPSK Eb/N0=0.5*Es/N0=0.5*SNR
%x = randi(1000000,1,M);
y=modulate(modem.qammod(M),mensaje);
ynoisy = awgn(y,SNR_dB,'measured');
z=demodulate(modem.qamdemod(M),ynoisy);
[num,rt]= symerr(mensaje,z);
SNR=[SNR EbN0];
SER=[SER rt];
end;

EbNo = 0:0.5:10;
[ber, ser] = berawgn(EbNo,'qam',M);
semilogy(SNR,SER,'-ro',SNR,ser,'-bo');grid;title('Symbol error rate for QAM over AWGN');
legend('BEP Simulado','BEP teorico QAM');
xlabel('E_b/N_0');ylabel('SER');
