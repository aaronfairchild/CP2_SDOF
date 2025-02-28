function [periods, Sa] = EarthquakeResponseSpectrum(ModelType, DampType, dParams, fourier_terms)
% EarthquakeResponseSpectrum - Generate response spectrum for earthquake loading
%   [periods, Sa] = EarthquakeResponseSpectrum(ModelType, DampType, dParams, fourier_terms) 
%   Computes and plots the pseudo-acceleration response spectrum for a SDOF 
%   system with specified constitutive model and damping type subjected to 
%   earthquake ground motion.
%
% Inputs:
%   ModelType - Constitutive model type (1-4)
%               1 = Linear Elastic
%               2 = Nonlinear stiffening model
%               3 = Nonlinear softening model
%               4 = Elastoplastic model
%   DampType - Damping model type (1-4, optional, default=1)
%               1 = Linear viscous (default)
%               2 = Coulomb friction
%               3 = Nonlinear viscous
%               4 = State-dependent viscous
%   dParams - Additional damping parameters (optional, see DampingForce.m)
%   fourier_terms - Number of terms to use in Fourier approximation (optional)
%                   If specified, uses Fourier approximation of earthquake
%                   Default: 0 (use original earthquake data)
%
% Outputs:
%   periods - Array of periods [s]
%   Sa - Pseudo-acceleration spectrum
%
% Example:
%   % Linear elastic with 5% viscous damping (just show plot)
%   EarthquakeResponseSpectrum(1);
%
%   % Elastoplastic with Coulomb friction (return data)
%   mu = 0.05; N = 2*9.81; % Friction coefficient and normal force
%   [T, Sa] = EarthquakeResponseSpectrum(4, 2, [mu, N, 0.001]);
%
%   % Linear elastic with 5% damping using 200 Fourier terms
%   [T, Sa] = EarthquakeResponseSpectrum(1, 1, [], 200);
%
% By Aaron Fairchild
% Date: February 27, 2025

% Input validation
if nargin < 1
    error('ModelType must be provided.');
end

% Default damping type if not provided
if nargin < 2 || isempty(DampType)
    DampType = 1; % Default to linear viscous damping
end

% Default damping parameters if not provided
if nargin < 3
    dParams = [];
end

% Default Fourier terms if not provided
if nargin < 4
    fourier_terms = 0; % Default to no Fourier approximation
end

% Set plotting preferences
set(0, 'DefaultTextInterpreter', 'latex');
set(0, 'DefaultAxesTickLabelInterpreter', 'latex');
set(0, 'DefaultLegendInterpreter', 'latex');
set(0, 'DefaultAxesFontSize', 14);
set(0, 'DefaultTextFontSize', 14);

% Parameters for response spectrum analysis
m = 100;                      % Mass
xi = 0.01;                  % Damping ratio (for viscous damping)
T_min = 0.01;                % Minimum period [s]
T_max = 3;                  % Maximum period [s]
nPts = 500;                 % Number of periods to evaluate
uo = 0;                     % Initial displacement
vo = 0;                     % Initial velocity

% Convert periods to frequencies
periods = logspace(log10(T_min), log10(T_max), nPts);
omega = 2*pi ./ periods;

% Read earthquake ground acceleration
[t, ag] = RealEq();
h = t(2) - t(1);            % Time step

% Apply Fourier approximation if requested
if fourier_terms > 0
    tic;
    fprintf('Using Fourier approximation with %d terms...\n', fourier_terms);
    [ag_approx, error_metrics] = CompareFourierApprox(t, ag, fourier_terms, false);
    ag = ag_approx;
    fprintf('Fourier approximation completed: RMSE = %.4e, Relative Error = %.2f%%\n', ...
        error_metrics.RMSE, error_metrics.RelativeError);
    toc;
end

ag = ag.*9.81; % now in m/s^2

% Set constitutive model parameters based on ModelType
switch ModelType
    case 1 % Linear Elastic
        b = 0;
        So = 0;
        modelName = 'Linear Elastic';
    case 2 % Nonlinear stiffening
        b = 1;  % Stiffening parameter
        So = 0;
        modelName = 'Nonlinear Stiffening';
    case 3 % Nonlinear softening
        b = 1;  % Softening parameter
        So = 0;
        modelName = 'Nonlinear Softening';
    case 4 % Elastoplastic
        b = 0;
        So = 4; % Yield stress
        modelName = 'Elastoplastic';
    otherwise
        error('Invalid ModelType. Must be 1-4.');
end

% Set damping type name
switch DampType
    case 1
        dampName = 'Linear Viscous';
    case 2
        dampName = 'Coulomb Friction';
    case 3
        dampName = 'Nonlinear Viscous';
    case 4
        dampName = 'State-dependent Viscous';
    otherwise
        error('Invalid DampType. Must be 1-4.');
end

% Initialize arrays for results
Sa = zeros(nPts, 1);        % Pseudo-acceleration spectrum
Sd = zeros(nPts, 1);        % Displacement spectrum

% Start timing the execution
tic;

% Compute response spectrum
fprintf('Computing response spectrum for %s model and %s damping...\n', modelName, dampName);
for i = 1:nPts
    k = omega(i)^2 * m;     % Stiffness for current frequency
    if ModelType == 4
        So = 0.02*k;
    end
    d = [ModelType, k, b, So]; % Constitutive model parameters
    
    % Set damping coefficient (only used for viscous damping)
    c = 2 * xi * omega(i) * m;
    
    % Run time history analysis with specified damping type and parameters
    LoadType = 0;  % No external loading (earthquake input is in ag)
    [U] = Newmark(h, LoadType, m, c, d, t(end), uo, vo, ag, DampType, dParams);
    

    % Extract maximum displacement
    Sd(i) = max(abs(U(:,2)))./9.81;
    
    % Compute pseudo-acceleration
    Sa(i) = omega(i)^2 * Sd(i);
end

% Measure total execution time
execution_time = toc;

% Plot
figure('Name', 'Earthquake Response Spectrum');
figSize = [0.3, 0.3, 0.6, 0.6];
set(gcf, 'Units', 'normalized', 'OuterPosition', figSize);

% Pseudo-acceleration vs Period
subplot(2,1,1); grid on; hold on;
plot(periods, Sa, 'b-', 'LineWidth', 2);
xlabel('Period $T$ (s)');
ylabel('Pseudo-acceleration $S_a = \omega^2 u_{max}$');
if fourier_terms > 0
    title_str = sprintf('%s, %s Damping (Fourier terms: %d)', modelName, dampName, fourier_terms);
else
    title_str = sprintf('%s, %s Damping', modelName, dampName);
end
title(title_str);
xlim([min(periods), max(periods)]);

% Plot earthquake accelerogram
subplot(2,1,2); grid on; hold on;
plot(t, ag, 'k-', 'LineWidth', 1);
xlabel('Time (s)');
ylabel('Ground Acceleration (g)');
if fourier_terms > 0
    title('Input Earthquake Accelerogram (Fourier Approximation)');
else
    title('Input Earthquake Accelerogram');
end

% Print a summary of parameters
fprintf('\nEARTHQUAKE RESPONSE SPECTRUM ANALYSIS\n\n');
fprintf('  MODEL PROPERTIES\n');
fprintf('  Model Type:                      %s (%d)\n', modelName, ModelType);
fprintf('  Damping Type:                    %s (%d)\n', dampName, DampType);
fprintf('  Mass:                           %6.3f\n', m);
fprintf('  Damping Ratio (viscous):        %6.3f\n\n', xi);

fprintf('  RESPONSE SPECTRUM PARAMETERS\n');
fprintf('  Minimum Period:                 %6.3f s\n', T_min);
fprintf('  Maximum Period:                 %6.3f s\n', T_max);
fprintf('  Number of Points:                %5d\n', nPts);
fprintf('  Maximum Pseudo-Acceleration:    %6.4f\n', max(Sa));
fprintf('  Total Execution Time:          %6.2f seconds\n\n', execution_time);

if fourier_terms > 0
    fprintf('  FOURIER APPROXIMATION\n');
    fprintf('  Number of Fourier Terms:       %5d\n', fourier_terms);
    fprintf('  RMSE:                         %6.4e\n', error_metrics.RMSE);
    fprintf('  Relative Error:              %6.2f%%\n\n', error_metrics.RelativeError);
end

% If no output arguments, clear return values
if nargout == 0
    clear periods Sa;
end

end