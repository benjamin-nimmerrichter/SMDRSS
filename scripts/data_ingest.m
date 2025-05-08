% pokud existuje var, tak neingestuj
% pokud neexistuje načti to
function S = data_ingest()
    % 0 deg
    load("4x stejne misto pro onset jitter_m.mat","meas");
    S(1) = meas;
    % 5 deg
    %load("measurement\fix_mereni_07_03_el5_m.mat","meas");
    %S(2) = meas;
    % 10 deg
    %load("measurement\fix_mereni_07_03_el10_m.mat","meas");
    %S(3) = meas;
    % 20 deg
    %load("measurement\fix_mereni_07_03_el20_m.mat","meas");
    %S(4) = meas;
    % 30 deg
    %load("measurement\fix_mereni_07_03_el30_m.mat","meas");
    %S(5) = meas;
    % 40 deg
    %load("measurement\fix_mereni_07_03_el40_m.mat","meas");
    %S(6) = meas;
end
