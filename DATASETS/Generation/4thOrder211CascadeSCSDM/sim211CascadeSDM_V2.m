%% Dataset Generation, 4th order 2-1-1 Cascade Multibit SDM
% P. Manrique Feb 20, 2024

clear;
clc;
close all;
tStart = cputime;

% Values for Bw between 10Mhz and 20Mhz; and for fs between 4Bw and
% min(512*2*Bw,300MHz)
addpath('..');
bw_fs = Bw_fs_range(false,5000,12);
Bw = bw_fs{1,1};
fs = bw_fs{1,2};

% Calculating OSR:
osr = round(fs./(2*Bw));
N_osr = log2(osr);
osr_pot2 = 2.^(round(N_osr)); % recalcular fs

% Recalculating fs
fs2 = 2.*Bw.*osr_pot2;
 
% Filtering OSR
valid_osr_idx = find(osr_pot2 <= 64);
OSR = osr_pot2(valid_osr_idx);

% Reshaping Bw and fs:
Bw = Bw(valid_osr_idx); % eliminar repetidos (bw,fs,osr)
fs3 = fs2(valid_osr_idx);

% Eliminating repeated values
triple = [Bw; OSR; fs3];
triplet = triple.';
tripleu = unique(triplet,'rows');

Bw = tripleu(:,1);
OSR = tripleu(:,2);
fs = tripleu(:,3);


n_sim = length(fs);
%%

% Rest of parameters
Adc = 10.^(2+1*rand(1,n_sim)); % Minimo 100
gm = 10.^(-4+2*rand(1,n_sim)); % minimo 10**-4
io = 10.^(-4+2*rand(1,n_sim));

fin = Bw./3;

%% Prepare Simulation Parameters Inputs
SDMmodel = 'umts211_real_PM';
load_system(SDMmodel);

SDin(1:n_sim) = Simulink.SimulationInput(SDMmodel);
for n = 1:n_sim   
   
    ts = 1./fs; 

    SDin(n) = SDin(n).setVariable('ts', ts(n));
    SDin(n) = SDin(n).setVariable('fs', fs(n));
    SDin(n) = SDin(n).setVariable('OSR', OSR(n));


    f = rand(3,1)*0.8+0.2;
    f = sort(f, 'descend');
    aux = Adc(n);
    auy = gm(n);
    auz = io(n);
    SDin(n) = SDin(n).setVariable('Adc1', aux); 
    SDin(n) = SDin(n).setVariable('gm1', auy);
    SDin(n) = SDin(n).setVariable('Io1', auz);

    SDin(n) = SDin(n).setVariable('Adc2', max(f(1)*aux,100)); % max(f(1)*aux,100)
    SDin(n) = SDin(n).setVariable('gm2', max(f(1)*auy,1e-4)); % "
    SDin(n) = SDin(n).setVariable('Io2', max(f(1)*auz,1e-4));

    SDin(n) = SDin(n).setVariable('Adc3', max(f(2)*aux,100));
    SDin(n) = SDin(n).setVariable('gm3', max(f(2)*auy,1e-4));
    SDin(n) = SDin(n).setVariable('Io3', max(f(2)*auz,1e-4));

    SDin(n) = SDin(n).setVariable('Adc4', max(f(3)*aux,100));
    SDin(n) = SDin(n).setVariable('gm4', max(f(3)*auy,1e-4));
    SDin(n) = SDin(n).setVariable('Io4', max(f(3)*auz,1e-4));

    SDin(n) = SDin(n).setVariable('Bw', Bw(n));
    SDin(n) = SDin(n).setVariable('fin',fin(n));

    fprintf(['Simulation input creation ',num2str(n/n_sim*100),'\n'])
end

disp(cputime - tStart)
% 
% Run parallel simulations
tStart2 = cputime;
fprintf('Running parallel simulations')
SDout=parsim(SDin,'ShowProgress','on','TransferBaseWorkspaceVariables','off',...
    'AttachedFiles','211CascadeSDM_GP.mat',...
    'SetupFcn',@()evalin('base','load 211CascadeSDM_GP.mat')); 
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

% Filtering simulations such that SNR > 50
valid_idx = find(snr > 50);
snr_v = snr(valid_idx);
bw = bw(valid_idx);
power = power(valid_idx);
osr = osr(valid_idx);
fs_d = fs_d(valid_idx);
adc1 = adc1(valid_idx);
gm1 = gm1(valid_idx);
io1 = io1(valid_idx);
adc2 = adc2(valid_idx);
gm2 = gm2(valid_idx);
io2 = io2(valid_idx);
adc3 = adc3(valid_idx);
gm3 = gm3(valid_idx);
io3 = io3(valid_idx);
adc4 = adc4(valid_idx);
gm4 = gm4(valid_idx);
io4 = io4(valid_idx);



data = [snr_v,bw,power,osr,fs_d,adc1,gm1,io1,adc2,gm2,io2,adc3,gm3,io3,adc4,gm4,io4];

data = array2table(data,'VariableNames',{'SNR', 'Bw','Power','OSR','fs','Adc1', 'gm1', 'Io1','Adc2', 'gm2', 'Io2','Adc3', 'gm3', 'Io3','Adc4', 'gm4', 'Io4'});
writetable(data,'211CascadeSDM_DataSet_longrun1.csv','WriteMode','overwrite')

disp(cputime - tStart)