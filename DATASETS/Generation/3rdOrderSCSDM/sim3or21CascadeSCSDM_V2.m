%% Dataset generation, 3rd order SC model
% P. Manrique Feb 20, 2024

clear;
clc;
close all;
tStart = cputime;

% Values for Bw between 10Mhz and 20Mhz; and for fs between 4Bw and
% min(512*2*Bw,300MHz)
addpath('..');
bw_fs = Bw_fs_range(false,10,6);
Bw = bw_fs{1,1};
fs = bw_fs{1,2};

% Calculating and filtering OSR:
osr = round(fs./(2*Bw));
N_osr = log2(osr);
osr_pot2 = 2.^(round(N_osr));
 
valid_osr_idx = find(osr_pot2 >= 32);
OSR = osr_pot2(valid_osr_idx);

% Reshaping Bw and fs:
Bw = Bw(valid_osr_idx);
fs = fs(valid_osr_idx);

n_sim = length(fs);

% Rest of parameters
fi = Bw./2;
Adc1 = 10.^(1+2*rand(1,n_sim));
gm1 = 10.^(-5+2*rand(1,n_sim));
io1 = 10.^(-4+2*rand(1,n_sim));

Adc2 = 10.^(1+2*rand(1,n_sim));
gm2 = 10.^(-5+2*rand(1,n_sim));
io2 = 10.^(-4+2*rand(1,n_sim));

%% Simulations
SDMmodel = 'ThirdOrderCascadeSingleBitSC_PMM';
load_system(SDMmodel);

SDin(1:n_sim) = Simulink.SimulationInput(SDMmodel);
for n = 1:n_sim   
    
    ts = 1./fs; 

    SDin(n) = SDin(n).setVariable('Ts', ts(n));
    SDin(n) = SDin(n).setVariable('fs', fs(n));

    SDin(n) = SDin(n).setVariable('M', OSR(n));

    SDin(n) = SDin(n).setVariable('ao1', Adc1(n));
    SDin(n) = SDin(n).setVariable('gm1', gm1(n));
    SDin(n) = SDin(n).setVariable('io1', io1(n));

    SDin(n) = SDin(n).setVariable('ao2', Adc2(n));
    SDin(n) = SDin(n).setVariable('gm2', gm2(n));
    SDin(n) = SDin(n).setVariable('io2', io2(n));

    SDin(n) = SDin(n).setVariable('Bw', Bw(n));


    fprintf(['Simulation input creation ',num2str(n/n_sim*100),'\n'])
end

disp(cputime - tStart)

% Run parallel simulations
tStart2 = cputime;
fprintf('Running parallel simulations')
SDout=parsim(SDin,'ShowProgress','on','TransferBaseWorkspaceVariables','off',...
    'AttachedFiles','3rdSCSDM_GP.mat',...
    'SetupFcn',@()evalin('base','load 3rdSCSDM_GP.mat')); 
disp(cputime - tStart2)
fprintf('Saving Data ...')
osr = reshape(arrayfun(@(obj) obj.Variables(3).Value, SDin), [], 1);

adc1 = reshape(arrayfun(@(obj) obj.Variables(4).Value, SDin), [], 1);
gm1 = reshape(arrayfun(@(obj) obj.Variables(5).Value, SDin), [], 1);
io1 = reshape(arrayfun(@(obj) obj.Variables(6).Value, SDin), [], 1);

adc2 = reshape(arrayfun(@(obj) obj.Variables(7).Value, SDin), [], 1);
gm2 = reshape(arrayfun(@(obj) obj.Variables(8).Value, SDin), [], 1);
io2 = reshape(arrayfun(@(obj) obj.Variables(9).Value, SDin), [], 1);

bw = reshape(arrayfun(@(obj) obj.Variables(10).Value, SDin), [], 1);
fs = reshape(arrayfun(@(obj) obj.Variables(2).Value, SDin), [], 1);

snr = reshape(arrayfun(@(obj) obj.SNRArray, SDout),[],1);

alfa = 0.05;
power = (io1 + io2)*(1 + alfa) + io2*(1+alfa);

% Filtering simulations such that SNR > 50
valid_idx = find(snr > 50);
osr = osr(valid_idx);
adc1 = adc1(valid_idx);
gm1 = gm1(valid_idx);
io1 = io1(valid_idx);
adc2 = adc2(valid_idx);
gm2 = gm2(valid_idx);
io2 = io2(valid_idx);
fs = fs(valid_idx);
bw = bw(valid_idx);
power = power(valid_idx);
snr = snr(valid_idx);


data = [snr,bw,power,osr,adc1,gm1,io1,adc2,gm2,io2,fs];

data = array2table(data,'VariableNames',{'SNR', 'Bw', 'Power', 'OSR', 'Adc1', 'gm1', 'Io1','Adc2', 'gm2', 'Io2','fs'});
writetable(data,'3or21CascadeSDM_DataSet3.csv','WriteMode','append')
