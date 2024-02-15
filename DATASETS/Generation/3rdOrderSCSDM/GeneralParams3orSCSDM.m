%% General Parameters for 3rd order SC SDM
% P. Manrique Feb 5, 2024

N=65536; Ain = 0.5;
kt=0.026*1.6e-19; 
Cint1=24e-12; 
Cs11=6e-12; % sampling capacitor (branch 1) 
Cs21=6e-12; % sampling capacitor (branch 2)
innoise1=0; % rms value of the input equivalent noise
ron1=60;

Cint2=3e-12;
Cs12=1.5e-12;
Cs22=1.5e-12;
innoise2=0;
ron2=650;

temp=175; % temperature
osp=2.7; % output swing
cnl1=0; % capacitor first-order non-linear coef.
cnl2=25e-6; % capacitor second-order non-linear coef.
avnl1=0; % DC gain first-order non-linear coef.
avnl2=15e-2; % DC gain second-order non-linear coef.
avnl3=0; % DC gain third-order non-linear coef.
avnl4=0; % DC gain fourth-order non-linear coef.
cpar1=0.6e-12; % parasitic (opamp) input capacitance
cpar2=0.6e-12;
cload=2.28e-12; % opamp (intrinsic) load capacitance
% Comparators
vref=2; % DAC reference voltage
hys=30e-3; % comparator hysteresis

% Save parameters
filename = '3rdSCSDM_GP.mat';
save(filename,'Ain','N','kt','Cint1','Cs11','Cs12','innoise1','ron1','Cint2','Cs12','Cs22','innoise2','ron2','temp','osp','cnl1','cnl2','avnl1','avnl2','avnl3','avnl4','cpar1','cpar2','cload','vref','hys')