%% Dataset generation of 2nd order SC SDM model
% P. Manrique Feb 20, 2024

clear;
clc;
close all;
tStart1 = cputime;

%% Preparing Simulation Parameters Input

% Values for Bw between 10Mhz and 20Mhz; and for fs between 4Bw and
% min(512*2*Bw,300MHz)
addpath('..');
bw_fs = Bw_fs_range(false,5000,12);
Bw = bw_fs{1,1};
fs = bw_fs{1,2};

% Calculating OSR:
osr = round(fs./(2*Bw));
N_osr = log2(osr);
osr_pot2 = 2.^(round(N_osr));
 
% Recalculating fs
fs2 = 2.*Bw.*osr_pot2;

% Filtering OSR
valid_osr_idx = find(osr_pot2 >= 32);
OSR = osr_pot2(valid_osr_idx);

% Reshaping Bw and fs:
Bw = Bw(valid_osr_idx);
fs3 = fs2(valid_osr_idx);

% Eliminating repeated values
triple = [Bw; OSR; fs3];
triplet = triple.';
tripleu = unique(triplet,'rows');

Bw = tripleu(:,1);
OSR = tripleu(:,2);
fs = tripleu(:,3);

n_sim = length(fs);

% Rest of parameters
fin = Bw./5;
Adc = 10.^(1+2*rand(1,n_sim));
gm = 10.^(-5+2*rand(1,n_sim));
io = 10.^(-4+2*rand(1,n_sim));
Vn = 10.^(-11+4*rand(1,n_sim));

%% Prepare Simulation Parameters Inputs
% from P.Diaz April 19, 2023
SDMmodel = 'SecondOrderSingleBitSC_PMM';
load_system(SDMmodel);
variables_filePath = '2ndSCSDM_GP.mat';

SDin(1:n_sim) = Simulink.SimulationInput(SDMmodel);
for n = 1:n_sim  
    ts=1./fs; 
    SDin(n) = SDin(n).setVariable('M', OSR(n));
    SDin(n) = SDin(n).setVariable('Adc', Adc(n));
    SDin(n) = SDin(n).setVariable('gm', gm(n));
    SDin(n) = SDin(n).setVariable('io', io(n));
    SDin(n) = SDin(n).setVariable('Vn', Vn(n));
    SDin(n) = SDin(n).setVariable('ts', ts(n));
    SDin(n) = SDin(n).setVariable('fs', fs(n));
    SDin(n) = SDin(n).setVariable('Bw', Bw(n));

    fprintf(['Simulation input creation ',num2str(n/n_sim*100),'\n'])
end            
    

% 
% Run parallel simulations
tStart2 = cputime;
fprintf('Running parallel simulations')
SDout=parsim(SDin,'ShowProgress','on','TransferBaseWorkspaceVariables','off',...
    'AttachedFiles',variables_filePath,...
    'SetupFcn',@()evalin('base','load 2ndSCSDM_GP.mat')); 
disp(cputime - tStart2)

%%
osr_dt = reshape(arrayfun(@(obj) obj.Variables(1).Value, SDin),[],1);
adc_dt = reshape(arrayfun(@(obj) obj.Variables(2).Value, SDin),[],1);
gm_dt = reshape(arrayfun(@(obj) obj.Variables(3).Value, SDin),[],1);
io_dt = reshape(arrayfun(@(obj) obj.Variables(4).Value, SDin),[],1);
vn_dt = reshape(arrayfun(@(obj) obj.Variables(5).Value, SDin),[],1);
fs_dt = reshape(arrayfun(@(obj) obj.Variables(7).Value, SDin),[],1);

bw_dt = reshape(arrayfun(@(obj) obj.Variables(8).Value, SDin),[],1);

alfa = 0.05;
power = 2*io_dt*(1 + alfa);
snr = reshape(arrayfun(@(obj) obj.SNRArray, SDout,'UniformOutput',false),[],1);


snr_array = cell2mat(snr);

% Filtering simulations such that SNR > 50
valid_idx = find(snr_array > 50);
osr_dt = osr_dt(valid_idx);
adc_dt = adc_dt(valid_idx);
gm_dt = gm_dt(valid_idx);
io_dt = io_dt(valid_idx);
vn_dt = vn_dt(valid_idx);
fs_dt = fs_dt(valid_idx);
bw_dt = bw_dt(valid_idx);
power = power(valid_idx);
snr_array = snr_array(valid_idx);

data = [snr_array,bw_dt,power,osr_dt,fs_dt,adc_dt,gm_dt,io_dt,vn_dt];
data = array2table(data,'VariableNames',{'SNR', 'Bw', 'Power', 'OSR', 'fs', 'Adc','gm','Io','Vn'});
writetable(data,'2ndSCSDM_DataSet_longrun1.csv','WriteMode','append')