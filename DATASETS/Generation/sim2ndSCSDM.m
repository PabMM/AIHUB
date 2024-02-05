%% Dataset generation, 2nd order SC model
% P. Manrique Feb 2, 2024

clear;
clc;
close all;

% Random values of Bw between 10kHz and 20MHz
Bwmin=1e4;
Bwmax=2e7;
n_Bw = 10;
logmin = log10(Bwmin);
logmax = log10(Bwmax);
Bw = 10.^(logmin + (logmax - logmin)*rand(1,n_Bw));

n_sim = 5*n_Bw;

% Values of fs and OSR
fs = [];
OSR = [];
for i = 1:n_Bw
    for k = [4 8 16 32 64]
        fs = [fs, 2*k*Bw(i)];
        OSR = [OSR, k];
    end
end

% Reshaping Bw vector
Bw = repelem(Bw,5);

% Deleting components k such that fs(k) > fmax
fmax = 3e8;
comps_to_delete = [];
for k = 1:n_sim
    if fs(k) > fmax
        comps_to_delete = [comps_to_delete, k];
    end
end
fs(comps_to_delete) = [];
OSR(comps_to_delete) = [];
Bw(comps_to_delete) = [];

n_sim = length(fs);

% Rest of parameters
fin = Bw./5;
Adc = 10.^(1+2*rand(1,n_sim));
gm = 10.^(-5+2*rand(1,n_sim));
io = 10.^(-4+2*rand(1,n_sim));
Vn = 10.^(-11+4*rand(1,n_sim));

%% Prepare Simulation Parameters Inputs
% from P.Diaz April 19, 2023
SDMmodel = 'SecondOrderSingleBitSC';
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
c1 = reshape(arrayfun(@(obj) obj.Variables(1).Value, SDin),[],1);
c2 = reshape(arrayfun(@(obj) obj.Variables(2).Value, SDin),[],1);
c3 = reshape(arrayfun(@(obj) obj.Variables(3).Value, SDin),[],1);
c4 = reshape(arrayfun(@(obj) obj.Variables(4).Value, SDin),[],1);
c5 = reshape(arrayfun(@(obj) obj.Variables(5).Value, SDin),[],1);


snr = reshape(arrayfun(@(obj) obj.SNRArray, SDout),[],1);
data = [snr,c1,c2,c3,c4,c5];
data = array2table(data,'VariableNames',{'SNR', 'OSR', 'Adc', 'gm', 'Io', 'Vn'});
writetable(data,'2ndSCSDM_DataSet_prueba.csv')