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

% Define default earthquake parameters for the benchmark case
eqParams = struct('so', 0.0125, ... % Magnitude
    'a', 2, ...        % Exponent for growth
    'b', 0.15, ...     % Exponent for decay
    'Amp', [0.2981 0.4472 0.5963 0.5963], ...
    'Freq', [1 2 5 10], ...
    'Phi', [0 0 0 0]);

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
[t, ~, vg, ag] = FakeEq(tf, h, EqOn, plotConfig, eqParams);

% Calculate response spectrum
[~] = ResponseSpectrum(t, h, ag, respParams, plotConfig);

% Print output
vgFinal = vg(end); beta = 0.25; gamma = 0.5; nSteps = ceil(tf/h);

fprintf('PoD 9: SDOF Earthquake\n\n')
fprintf('  EARTHQUAKE CHARACTERISTICS\n');
fprintf('  Earthquake Duration (tD)         %6.3f\n', tf);
fprintf('  Time increment (dt)              %6.3f\n', h);
fprintf('  Number of time steps            %7i\n', nSteps);
fprintf('  Earthquake type                 %7s\n', 'unknown');
fprintf('  Time shape fcn parameters :      %6.3f %6.3f %6.3f\n', ...
    eqParams.a, eqParams.b, eqParams.so);
fprintf('     Amp      Freq      Phase\n');
for i = 1:length(eqParams.Amp)
    fprintf('  %6.3f    %6.3f     %6.3f\n', ...
        eqParams.Amp(i), eqParams.Freq(i), eqParams.Phi(i));
end

fprintf('\n  Final velocity: %1.4e\n\n', vgFinal);

fprintf('  PHYSICAL PROPERTIES\n');
fprintf('  Initial Natural Frequency       %6.3f\n', respParams.omegaMin);
fprintf('  Final Natural Frequency         %6.3f\n', respParams.omegaMax);
fprintf('  Number of Frequency Points     %7i\n', respParams.nPts);
fprintf('  Damping ratio                   %6.3f\n\n', respParams.xi);

fprintf('  INTEGRATION OF EQUATIONS\n');
fprintf('  Final time (tf)                 %6.3f\n', tf);
fprintf('  Time increment (h)              %6.3f\n', h);
fprintf('  Numerical integration (beta)    %6.3f\n', beta);
fprintf('  Numerical integration (gamma)   %6.3f\n', gamma);
fprintf('  Number of time steps           %7i\n\n', nSteps);
end