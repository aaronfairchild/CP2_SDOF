% PoD 9: Response Spectrum and Earthquake Response
% Code by: Aaron Fairchild
% Original: February 12, 2025
% Latest Update: February 24, 2025

function PoD9()
tf = 80;
h = 0.02;
EqOn = 1; % Earthquake generation on

% Create a plotting configuration structure
plotConfig = struct('showEqPlots', true, ...   % Show earthquake plots
    'showRespPlots', true, ... % Show response spectrum plots
    'showTimeHistory', true);  % Show time history for selected frequency

% Define default ResponseSpectrum parameters for the benchmark case
respParams = struct('omegaMin', 0.3, ...
    'omegaMax', 10, ...
    'nPts', 500, ...
    'xi', 0.1, ...
    'wCheckIdx', 40, ...
    'm', 1, ...
    'uo', 0, ...
    'vo', 0);

% Generate earthquake
[ag, t] = FakeEq(tf, h, EqOn, plotConfig);

% Calculate response spectrum
[Resp] = ResponseSpectrum(t, h, ag, respParams, plotConfig);
end