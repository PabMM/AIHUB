%% Fixed Parameters for GmC 2nd Order CT SDM model
% P. Manrique Feb 15, 2024 - From J.M. de la Rosa Feb 6, 2024

%% Simulation parameters
% General parameters (Input signal, BW, fs, Vref...)
Ain_dBFS=-6; %Input ampl. (dBFS)
Ain=10.^(Ain_dBFS./20); %Input ampl. for simulation model
N=2^16; % N. of points (clock cycles)
%OSR=64;% OSR
%fs=1e9; % Sampling freq.
%BW=fs/(2*OSR);% Signal bandwidth 
%fin=BW/(3*1.01234566); % Input freq. tone
%fin=BW/7*0.991234223;
%ts=1/fs;Ts=ts; %Sampling time
Vr=1; % Ref. voltage
T=300; % Temperature
eCT11=0;eCT12=0;eCT21=0;eCT22=0; % Excess-Loop Delay param. (ideal values)

%% CT-SDM Loop-Filter (LF) coefficients
d=1;
g11=1/4;
g12=1/4;
gq1=4;
gq2=4;
f11=(5/(2*g11))/gq1;
f12=(1/(g11*g12))/gq1;
fi=1/gq1;
kr=2/gq1;
g21=1/4;
g22=1/4;
f21=(5/(2*g11))/gq1;
f22=(1/(g11*g12))/gq1;
fi2=1/gq1;
kr2=2/gq1;
%% Quantizer
vhigh=Vr; 
vlow=-Vr;
n_levels=3; % Number of quantization levels
B=log2(n_levels); % Number of bits

%% GmC Integrators

% Main parameters
% gm=3e-4; % Master transconductance ---- gm
% vos_gm=20; % Output-Swing
% vis_gm=20; % Input-Swing
% 
% kgm12=1;
% gm11=gm; % Int1 transconductor
% gm12=kgm12*gm; % Int2 transconductor
% C1=(gm11/fs)/g11; % Integrator Capacitor 1
% C2=(gm12/fs)/g12; % Integrator Capacitor 2

% Non-ideal parameters

% % DC Gain
% Av11dB=1000; % Int1 (log) DC gain  ----- Adc
% Adc11=10.^(Av11dB./20); % Int1. (lin) DC gain
% R11=Adc11/gm11; % Rout parameter for the Gm-RC model
% Av12dB=1000; % Int2 (log) DC gain
% Adc12=10.^(Av12dB./20); % Int2 (lin) DC gain
% R12=Adc12/gm12; % Rout parameter for the Gm-RC model
% 
% % GBW
% GBW1=10e15; % Int1 GBW ------ GBW
% GBW1=fs;
% Cp1=gm11/(2*pi*GBW1); % Parasitic capacitance for the Gm-RC model
% GBW2=10e15; % Int2 GBW
% GBW2=fs;
% Cp2=gm12/(2*pi*GBW2); % Parasitic capacitance for the Gm-RC model
% 
% % 3rd-order Intermodulation Intercept. Point (IIP3)
% IIP3_in=1000; % IIP3 Int1
% IIP3_12=1000; % IIP3 Int2
% IIP3_a=1000; % IIP3 LF coef. Gm2
% IIP3_b=1000; % IIP3 LF coef. Gm3
% IIP3_c=1000; % IIP3 LF coef. Gm5
% 
% % Power estimation
% Pot=(gm11+gm12+gm*fi+gm*f11+gm*f12)*Vr^2+0.05*gm*(2^B-1)*Vr^2;
% PotmW=Pot*1e3;

%% Save parameters

save('GmC2ndOrderCTSDM_GP.mat')