%% General Parameters for 4th order 2-1-1 Cascade SC SDM
% P. Manrique Feb 7, 2024

clear; clc; clf;

% INPUT PARAMETERS
L=4; FS=2; % FS=2*Vref=1, where Vref stands for the differential reference voltage
B=3; INL_FS=0.07;

Delta3=FS/(2^3-1);
INL_LSB=INL_FS/100*FS/Delta3;

Vr=FS/2; N=65536;
Ain=0.5;

% INTEGRATOR PARAMETERS

Avnl1=0; Avnl2=0.1; cnl1=0; cnl2=0; %% ADDED/MODIFIES PARAMETERS COMPARED TO PREVIOUS EXERCISE

cp1=0.1e-15; cp2=0.1e-15;
cu=0.4e-12; cl=0.5e-15;

vosp=5; Ron=1;

T = 300;

cs1=cu;  ci1 =4*cs1;             %% INTEG 1: gain 0.25
cs2a=cu; cs2b=cs2a; ci2=2*cs2a;  %% INTEG 2: gain 1, 0.5
cs3a=cu; cs3b=cs3a; ci3=2*cs3a;  %% INTEG 3: gain 1, 0.5, 0.5
cs4a=cu; cs4b=cs3a; ci4=cs4a;    %% INTEG 4: gain 2, 1, 1

% INHERITED PARAMETERS
vhigh=Vr; vlow=-Vr;


save('211CascadeSDM_GP.mat');