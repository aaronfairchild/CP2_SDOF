% Validation script for Coulomb friction damping
% This script compares the numerical solution (Newmark method) with 
% the analytical solution for a SDOF system with Coulomb friction damping

% Define system parameters (matching PoD6b)
m = 2;              % Mass
k = 5;              % Stiffness
mu = 0.05;          % Coefficient of friction
g = 9.81;           % Gravitational acceleration
omega = sqrt(k/m);  % Natural frequency
uo = 3;             % Initial displacement
vo = 0;             % Initial velocity (must be zero for analytical solution)

% Simulation parameters
tf = 35;            % Final time
h = 0.01;           % Time step for numerical solution
nPts = ceil(tf/h);  % Number of points
nPtsAnalytical = 500; % Number of points for analytical solution (smoother curve)

% Initialize arrays for ground acceleration (zero)
ag = zeros(nPts, 1);

% Run analytical solution
fprintf('Running analytical solution...\n');
Uanalytical = CoulombAnalytical(m, k, mu, g, uo, vo, tf, nPtsAnalytical);

% Run numerical solution with Newmark method
fprintf('Running numerical solution...\n');
% Set up parameters for Newmark method
LoadType = 0;       % No external loading
d = [1, k, 0, 0];   % [ModelType, k, b, So] - Linear elastic model

% Run simulation with Coulomb damping
fprintf('Running Newmark method with Coulomb damping...\n');
N = m * g;          % Normal force
v_reg = 0.001;      % Regularization parameter
Unumerical = Newmark(h, LoadType, m, 0, d, tf, uo, vo, ag, 2, [mu, N, v_reg]);

% Extract results
t_analytical = Uanalytical(:,1);
u_analytical = Uanalytical(:,2);
v_analytical = Uanalytical(:,3);
a_analytical = Uanalytical(:,4);
fd_analytical = Uanalytical(:,5);

t_numerical = Unumerical(:,1);
u_numerical = Unumerical(:,2);
v_numerical = Unumerical(:,3);
a_numerical = Unumerical(:,4);
fd_numerical = Unumerical(:,6); % Damping force is in column 6

% Create comparison plots
figure('Name', 'Coulomb Damping Validation', 'Position', [100, 100, 1200, 800]);

% Displacement comparison
subplot(2,2,1); grid on; hold on;
plot(t_analytical, u_analytical, 'b-', 'LineWidth', 2);
plot(t_numerical, u_numerical, 'r--', 'LineWidth', 1.5);
xlabel('Time (s)'); ylabel('Displacement');
title('Displacement Comparison');
legend('Analytical', 'Numerical', 'Location', 'best');

% Velocity comparison
subplot(2,2,2); grid on; hold on;
plot(t_analytical, v_analytical, 'b-', 'LineWidth', 2);
plot(t_numerical, v_numerical, 'r--', 'LineWidth', 1.5);
xlabel('Time (s)'); ylabel('Velocity');
title('Velocity Comparison');
legend('Analytical', 'Numerical', 'Location', 'best');

% Phase space comparison
subplot(2,2,3); grid on; hold on;
plot(u_analytical, v_analytical, 'b-', 'LineWidth', 2);
plot(u_numerical, v_numerical, 'r--', 'LineWidth', 1.5);
xlabel('Displacement'); ylabel('Velocity');
title('Phase Space Comparison');
legend('Analytical', 'Numerical', 'Location', 'best');

% Friction force comparison
subplot(2,2,4); grid on; hold on;
plot(t_analytical, fd_analytical, 'b-', 'LineWidth', 2);
plot(t_numerical, fd_numerical, 'r--', 'LineWidth', 1.5);
xlabel('Time (s)'); ylabel('Friction Force');
title('Friction Force Comparison');
legend('Analytical', 'Numerical', 'Location', 'best');

% Create error plots
figure('Name', 'Coulomb Damping Error Analysis', 'Position', [100, 100, 1200, 400]);

% Interpolate analytical solution to match numerical time points
u_analytical_interp = interp1(t_analytical, u_analytical, t_numerical);
v_analytical_interp = interp1(t_analytical, v_analytical, t_numerical);
fd_analytical_interp = interp1(t_analytical, fd_analytical, t_numerical);

% Calculate errors
u_error = u_numerical - u_analytical_interp;
v_error = v_numerical - v_analytical_interp;
fd_error = fd_numerical - fd_analytical_interp;

% Remove NaN values (may occur at the end of interpolation)
valid_idx = ~isnan(u_analytical_interp);
t_valid = t_numerical(valid_idx);
u_error = u_error(valid_idx);
v_error = v_error(valid_idx);
fd_error = fd_error(valid_idx);

% Plot errors
subplot(1,3,1); grid on; hold on;
plot(t_valid, u_error, 'k-', 'LineWidth', 1.5);
xlabel('Time (s)'); ylabel('Displacement Error');
title('Displacement Error');

subplot(1,3,2); grid on; hold on;
plot(t_valid, v_error, 'k-', 'LineWidth', 1.5);
xlabel('Time (s)'); ylabel('Velocity Error');
title('Velocity Error');

subplot(1,3,3); grid on; hold on;
plot(t_valid, fd_error, 'k-', 'LineWidth', 1.5);
xlabel('Time (s)'); ylabel('Friction Force Error');
title('Friction Force Error');

% Calculate and print error statistics
fprintf('\nERROR STATISTICS:\n');
fprintf('Displacement: RMS Error = %.6f, Max Error = %.6f\n', ...
    rms(u_error), max(abs(u_error)));
fprintf('Velocity: RMS Error = %.6f, Max Error = %.6f\n', ...
    rms(v_error), max(abs(v_error)));
fprintf('Friction Force: RMS Error = %.6f, Max Error = %.6f\n', ...
    rms(fd_error), max(abs(fd_error)));

% Analysis of friction damping characteristics
a1 = mu*m*g/k;  % Static displacement due to friction
fprintf('\nFRICTION CHARACTERISTICS:\n');
fprintf('Static displacement (a1) = %.6f\n', a1);
fprintf('Friction force magnitude = %.6f\n', mu*m*g);

% Find when system stops (if it does)
stop_idx_analytical = find(abs(diff(u_analytical)) < 1e-10, 1);
stop_idx_numerical = find(abs(diff(u_numerical)) < 1e-10, 1);

if ~isempty(stop_idx_analytical)
    fprintf('\nAnalytical solution stops at t = %.4f s\n', t_analytical(stop_idx_analytical));
    fprintf('Final displacement = %.6f\n', u_analytical(stop_idx_analytical));
end

if ~isempty(stop_idx_numerical)
    fprintf('\nNumerical solution stops at t = %.4f s\n', t_numerical(stop_idx_numerical));
    fprintf('Final displacement = %.6f\n', u_numerical(stop_idx_numerical));
end