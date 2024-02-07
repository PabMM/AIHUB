%% Dataset Generation, 4th order 2-1-1 Cascade Multibit SDM
% P. Manrique Feb 7, 2024

clear;
clc;
close all;
tStart = cputime;

% Random values of Bw between 10kHz and 20MHz
Bwmin=1e4;
Bwmax=2e7;
n_Bw = 10;
logmin = log10(Bwmin);
logmax = log10(Bwmax);
Bw = 10.^(logmin + (logmax - logmin)*rand(1,n_Bw));

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
%%
% Deleting components k such that fs(k) > fmax
fmax = 3e8;
comps_to_delete = find(fs > fmax);

fs(comps_to_delete) = [];
OSR(comps_to_delete) = [];
Bw(comps_to_delete) = [];

n_sim = length(fs);

% Rest of parameters
Adc = 10.^(1+2*rand(1,n_sim));
gm = 10.^(-5+2*rand(1,n_sim));
io = 10.^(-4+2*rand(1,n_sim));

%% Prepare Simulation Parameters Inputs
SDMmodel = 'umts211_real';
load_system(SDMmodel);

SDin(1:n_sim) = Simulink.SimulationInput(SDMmodel);
for n = 1:n_sim   
   
    ts = 1./fs; 

    SDin(n) = SDin(n).setVariable('ts', ts(n));
    SDin(n) = SDin(n).setVariable('fs', fs(n));
    SDin(n) = SDin(n).setVariable('OSR', OSR(n));


    f = rand(3,1)*0.8+0.2;
    aux = Adc(n);
    auy = gm(n);
    auz = io(n);
    SDin(n) = SDin(n).setVariable('Adc1', aux);
    SDin(n) = SDin(n).setVariable('gm1', auy);
    SDin(n) = SDin(n).setVariable('Io1', auz);

    SDin(n) = SDin(n).setVariable('Adc2', f(1)*aux);
    SDin(n) = SDin(n).setVariable('gm2', f(1)*auy);
    SDin(n) = SDin(n).setVariable('Io2', f(1)*auz);

    SDin(n) = SDin(n).setVariable('Adc3', f(2)*aux);
    SDin(n) = SDin(n).setVariable('gm3', f(2)*auy);
    SDin(n) = SDin(n).setVariable('Io3', f(2)*auz);

    SDin(n) = SDin(n).setVariable('Adc4', f(3)*aux);
    SDin(n) = SDin(n).setVariable('gm4', f(3)*gm(n));
    SDin(n) = SDin(n).setVariable('Io4', f(3)*auz);

    SDin(n) = SDin(n).setVariable('Bw', Bw(n));
    
    fprintf(['Simulation input creation ',num2str(n/n_sim*100),'\n'])
end

disp(cputime - tStart)
% 
% Run parallel simulations
tStart2 = cputime;
fprintf('Running parallel simulations')
SDout=parsim(SDin,'ShowProgress','on','TransferBaseWorkspaceVariables','off',...
    'AttachedFiles','211CascadeSDM_Variables.mat',...
    'SetupFcn',@()evalin('base','load 211CascadeSDM_Variables.mat')); 
disp(cputime - tStart2)

%%
fprintf('Saving Data ...')
fs_d = reshape(arrayfun(@(obj) obj.Variables(2).Value, SDin), [], 1);
osr = reshape(arrayfun(@(obj) obj.Variables(3).Value, SDin), [], 1);
adc1 = reshape(arrayfun(@(obj) obj.Variables(4).Value, SDin), [], 1);
gm1 = reshape(arrayfun(@(obj) obj.Variables(5).Value, SDin), [], 1);
io1 = reshape(arrayfun(@(obj) obj.Variables(6).Value, SDin), [], 1);
adc2 = reshape(arrayfun(@(obj) obj.Variables(7).Value, SDin), [], 1);
gm2 = reshape(arrayfun(@(obj) obj.Variables(8).Value, SDin), [], 1);
io2 = reshape(arrayfun(@(obj) obj.Variables(9).Value, SDin), [], 1);
adc3 = reshape(arrayfun(@(obj) obj.Variables(10).Value, SDin), [], 1);
gm3 = reshape(arrayfun(@(obj) obj.Variables(11).Value, SDin), [], 1);
io3 = reshape(arrayfun(@(obj) obj.Variables(12).Value, SDin), [], 1);
adc4 = reshape(arrayfun(@(obj) obj.Variables(13).Value, SDin), [], 1);
gm4 = reshape(arrayfun(@(obj) obj.Variables(14).Value, SDin), [], 1);
io4 = reshape(arrayfun(@(obj) obj.Variables(15).Value, SDin), [], 1);
bw = reshape(arrayfun(@(obj) obj.Variables(16).Value, SDin), [], 1);
snr = reshape(arrayfun(@(obj) obj.SNRArray1, SDout),[],1);

% power consumption estimation
alfa = 0.05;
B = 3;
io_avg = 0.25*(io1+io2+io3+io4);
pq = alfa*(1+1+(2^B - 1))*io_avg;
power = io1 + io2 + io3 + io4 + pq;

data = [snr,bw,power,osr,fs_d,adc1,gm1,io1,adc2,gm2,io2,adc3,gm3,io3,adc4,gm4,io4];

data = array2table(data,'VariableNames',{'SNR', 'OSR','Power', 'Adc', 'gm1', 'Io1','Adc2', 'gm2', 'Io2','Adc3', 'gm3', 'Io3','Adc4', 'gm4', 'Io4'});
writetable(data,'211CascadeSDM_DataSet_prueba.csv','WriteMode','append')


disp(cputime - tStart)