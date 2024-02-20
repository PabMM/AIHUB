function bw_fs = Bw_fs_range(type,Bw_steps,fs_steps)
% If type = true (for GmC model), it generates a list of Bw_steps values
% for Bw; and if type = false (SC models), it generates a list of Bw values
% and fs values, both of length Bw_steps*fs_steps.
Bw_min = 10e3;
l1 = log10(Bw_min);
if type
    Bw_max = 200e6;
    l2 = log10(Bw_max);
    Bw = logspace(l1,l2,Bw_steps);
    bw_fs = Bw;
else
    Bw_max = 20e6;
    l2 = log10(Bw_max);
    Bw = logspace(l1,l2,Bw_steps);
    lbw = length(Bw);
    fs = zeros(1,fs_steps*lbw);
    i = 1;
    for bw = Bw
        fs_min = 4*bw;
        fs_max = min(512*2*bw,300e6);
        fs(i:(i+fs_steps-1)) = logspace(log10(fs_min),log10(fs_max),fs_steps);
        i = i+fs_steps;
    end
    Bw = repelem(Bw,fs_steps);
    bw_fs = {Bw,fs};
end
end