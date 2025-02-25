% PoD 8b: Fourier Approximation
% Code by: Aaron Fairchild
% Original: February 11, 2025
% Latest Update: February 25, 2025

function PoD8b()

set(0, 'DefaultTextInterpreter', 'latex');
set(0, 'DefaultAxesTickLabelInterpreter', 'latex');
set(0, 'DefaultLegendInterpreter', 'latex');
set(0, 'DefaultAxesFontSize', 14);
set(0, 'DefaultTextFontSize', 14);

% Input
T = 1;                % Period
k = 5;                % Stiffness
po = 2;               % Magnitude of forcing function
omega = 8;            % Natural Frequency
xi = 0.1;             % Damping ratio
OMEGA = 2*pi/T;       % Driving Frequency
beta = OMEGA/omega;   % Frequency ratio

nOrder = 300;          % order of approximation

to = 0; tf = 2*T; nPts = 2000;
t = linspace(to, tf, nPts);

ao = po/2;
p = ao;
u = ao/k;

for n = 1:nOrder
    Dn = (1-beta^2*n^2)^2 + (2*xi*beta*n)^2;
    phin = atan((2*xi*beta*n)/(1-beta^2*n^2));
    OMEGAn = OMEGA*n;

    % assign coefficents
    if mod(n,2) == 0
        an = 0;
    else
        an = -4*po./(n.^2.*pi.^2);
    end
    bn = 0;

    p = p + an.*cos(OMEGAn.*t);
    u = u + (1/(k*sqrt(Dn))) * (an*cos(OMEGAn.*t - phin));
end

% Plotting
figure('Name','PoD 8b Benchmark'); clf;
figsize = [0.5,0.6,0.4,0.4];
set(gcf, 'Units','normalized','OuterPosition', figsize)

% Forcing Function
subplot(1,2,1); grid on; hold on; grid minor;
plot(t, p,'-k', 'LineWidth', 2);
xlabel('$t$', 'Interpreter', 'latex');
ylabel('$p(t)$', 'Interpreter', 'latex');
title('Fourier Series Approx. of Loading');
grid on;

% Response
subplot(1,2,2); grid on; hold on; grid minor;
plot(t, u,'-k', 'LineWidth', 2);
xlabel('$t$', 'Interpreter', 'latex');
ylabel('$u(t)$', 'Interpreter', 'latex');
title('Steady-State Response');
grid on;
end