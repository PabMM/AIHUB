%% Representar gráficamente el dataset data_classifier_total

clc;
clear;
close all;

% Leer los datos
table = readtable('data_classifier_total_cod.csv');
data = table2array(table(2:end, :));


figure;

% Create scatter plots for each class with custom legend labels
uniqueLabels = unique(data(:, 4));

legendLabels = {'2orSCSDM', '211CascadeSDM', '3orCascadeSDM', '2orGMSDM'}; % Add your custom labels here

for i = 1:length(uniqueLabels)
    currentClass = uniqueLabels(i);
    indices = (data(:, 4) == i - 1);
    
    scatter3(data(indices, 1), data(indices, 2), data(indices, 3), 5, data(indices, 4), 'filled', 'DisplayName', legendLabels{i}, 'MarkerFaceAlpha', 0.6);
    hold on;
end

xlabel('SNR');
ylabel('OSR');
zlabel('Power');
title('Representación del dataset total de los clasificadores');

% Show the legend with custom labels
legend('Location', 'Best');

% Save the figure
saveas(gcf, 'totalm3D.png');
