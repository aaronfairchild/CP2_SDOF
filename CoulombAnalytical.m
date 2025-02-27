function [U] = CoulombAnalytical(m, k, mu, g, uo, vo, tf, nPts)
% Analytical solution for SDOF system with Coulomb friction damping
%
% Inputs:
%   m - Mass
%   k - Stiffness
%   mu - Coefficient of friction
%   g - Gravitational acceleration
%   uo - Initial displacement
%   vo - Initial velocity
%   tf - Final time
%   nPts - Number of time points
%
% Output:
%   U - [t, u, v, a, fd] time history where:
%       t - Time
%       u - Displacement
%       v - Velocity
%       a - Acceleration
%       fd - Friction damping force
%
% Based on PoD6b by Aaron Fairchild

% Calculate natural frequency if not provided in the original code
omega = sqrt(k/m);

% Create time vector
t = linspace(0, tf, nPts)';

% Initialize output arrays
u = zeros(nPts, 1);
v = zeros(nPts, 1);
a = zeros(nPts, 1);
fd = zeros(nPts, 1);

% Coefficients to simplify equations
th = pi/omega;  % Half-period

a1 = mu*m*g/k;  % Static displacement due to friction
A = uo - a1;    % Initial amplitude coefficient
B = a1;         % Offset coefficient

% Initialize first point
u(1) = uo;
if vo ~= 0
    error('This analytical solution assumes zero initial velocity');
end
v(1) = vo;
c = -1;  % Initial velocity sign (negative means moving toward origin)

% Main calculation loop
for i = 2:nPts
    n = floor(t(i)/th);         % Current interval
    nold = floor(t(i-1)/th);    % Previous interval

    if n ~= nold  % If we are at a new interval (velocity sign change)
        % Calculate previous displacement to check for stopping
        uold = A*cos(omega*(t(i-1)-nold*th)) + B;
        
        % Check if amplitude is less than static displacement (stopping condition)
        if abs(uold) < a1
            % System stops due to friction
            u(i:end) = uold;
            v(i:end) = 0;
            a(i:end) = 0;
            fd(i:end) = -k * uold;  % Static friction force balances spring
            break;
        end

        % Update coefficients for velocity sign change
        A = -1 * (A + c*2*a1);
        B = -B;
        c = -c;  % Toggle velocity sign
    end

    % Calculate displacement
    time_in_interval = t(i) - n*th;
    u(i) = A*cos(omega*time_in_interval) + B;
    
    % Calculate velocity and acceleration
    v(i) = -A*omega*sin(omega*time_in_interval);
    a(i) = -A*omega^2*cos(omega*time_in_interval);
    
    % Calculate friction force (always opposes motion)
    if v(i) ~= 0
        fd(i) = -mu*m*g*sign(v(i));
    else
        % When velocity is zero, friction force balances other forces
        fd(i) = -k*u(i);
        if abs(fd(i)) > mu*m*g
            fd(i) = mu*m*g*sign(fd(i));
        end
    end
end

% Assemble output matrix
U = [t, u, v, a, fd];

% Show plot if no output argument is requested
if nargout == 0
    plotCoulombResults(U, m, k, mu, omega, g, uo, vo);
end
end

function plotCoulombResults(U, m, k, mu, omega, g, uo, vo)
% Helper function to plot results from analytical solution

t = U(:,1);
u = U(:,2);
v = U(:,3);
a = U(:,4);
fd = U(:,5);

figure('Name', 'Coulomb Analytical Solution');
subplot(3,2,1); grid on; hold on;
plot(t, u, 'b-', 'LineWidth', 1.5);
xlabel('Time (s)'); ylabel('Displacement');
title('Displacement vs. Time');

subplot(3,2,2); grid on; hold on;
plot(t, v, 'r-', 'LineWidth', 1.5);
xlabel('Time (s)'); ylabel('Velocity');
title('Velocity vs. Time');

subplot(3,2,3); grid on; hold on;
plot(t, a, 'g-', 'LineWidth', 1.5);
xlabel('Time (s)'); ylabel('Acceleration');
title('Acceleration vs. Time');

subplot(3,2,4); grid on; hold on;
plot(t, fd, 'm-', 'LineWidth', 1.5);
xlabel('Time (s)'); ylabel('Friction Force');
title('Friction Force vs. Time');

subplot(3,2,5); grid on; hold on;
plot(u, v, 'k-', 'LineWidth', 1.5);
xlabel('Displacement'); ylabel('Velocity');
title('Phase Space');

subplot(3,2,6); grid on; hold on;
plot(u, fd, 'r-', 'LineWidth', 1.5);
xlabel('Displacement'); ylabel('Friction Force');
title('Hysteresis Loop');

% Print output
fprintf('Coulomb Friction Analytical Solution\n\n')
fprintf('  PHYSICAL PROPERTIES\n');
fprintf('  Mass                             %6.3f\n', m);
fprintf('  Stiffness                        %6.3f\n', k);
fprintf('  Coefficient of friction          %6.3f\n', mu);
fprintf('  Natural Frequency                %6.3f\n', omega);
fprintf('  Acceleration of gravity          %6.3f\n\n', g);

fprintf('  INITIAL CONDITIONS\n');
fprintf('  Initial displacement (uo)        %6.3f\n', uo);
fprintf('  Initial velocity (vo)            %6.3f\n\n', vo);

a1 = mu*m*g/k;
fprintf('  FRICTION CHARACTERISTICS\n');
fprintf('  Static displacement (a1)         %6.3f\n', a1);
fprintf('  Friction force magnitude         %6.3f\n\n', mu*m*g);
end