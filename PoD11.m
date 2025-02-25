% PoD 11: Nonlinear Elastoplastic
% Code by: Aaron Fairchild
% Original: February 19, 2025
% Latest Update: February 24, 2025

function PoD11()
set(0, 'DefaultTextInterpreter', 'latex');
set(0, 'DefaultAxesTickLabelInterpreter', 'latex');
set(0, 'DefaultLegendInterpreter', 'latex');
set(0, 'DefaultAxesFontSize', 14);
set(0, 'DefaultTextFontSize', 14);

% Input physical parameters
k = 5;
m = 1;
xi = 0.0;
b = 1;

omega = sqrt(k/m);
c = 2*xi*omega*m;

LoadType = 3;  % steady sinusoidal
ModelType = 4; % Elastoplastic
So = 4;  % yield stress

uo = 0.0;
vo = 0.0;
tf = 7;
h = 0.01;


nSteps = ceil(tf/h);
ag = zeros(nSteps, 1); % No earthquake for benchmark

d = [ModelType, k, b, So];
[U_EP] = Newmark(h,LoadType,m,c,d,tf,uo,vo,ag);

% Plot
figure('Name','PoD 11 Benchmark'); clf;
figsize = [0,0.1,0.4,0.6];
set(gcf, 'Units','normalized','OuterPosition', figsize)

% Responses vs. Time
subplot(2,3,1); grid on; hold on;
xlim([0,tf]);
plot(U_EP(:,1),U_EP(:,2),'b-','LineWidth',2)
xlabel('$t$'); ylabel('$u(t)$')
title('Response vs. Time')

% Velocity vs. Time
subplot(2,3,2); grid on; hold on;
xlim([0,tf]);
plot(U_EP(:,1),U_EP(:,3),'k-','LineWidth',2)
xlabel('$t$'); ylabel('$v(t)$')
title('Velocity vs. Time')

% Acceleration vs. Time
subplot(2,3,3); grid on; hold on;
xlim([0,tf]);
plot(U_EP(:,1),U_EP(:,4),'k-','LineWidth',2)
xlabel('$t$'); ylabel('$a(t)$')
title('Acceleration vs. Time')

% Force vs. time
subplot(2,3,4); grid on; hold on;
xlim([0,tf]);
plot(U_EP(:,1),U_EP(:,5),'k-','LineWidth',2)
xlabel('$r$'); ylabel('$t$')
title('Force vs. Time')

% Force vs. Displacement
subplot(2,3,5); grid on; hold on;
plot(U_EP(:,2),U_EP(:,5),'k-','LineWidth',2)
xlabel('$u(t)$'); ylabel('$r$')
title('Force vs. Displacement')

% Plastic strain vs. time
subplot(2,3,6); grid on; hold on;
xlim([0,tf]);
plot(U_EP(:,1),U_EP(:,6),'k-','LineWidth',2)
xlabel('$t$'); ylabel('$\varepsilon_{p}$')
title('Plastic Strain vs. Time')

% Print output
fprintf('PoD 11  SDOF NONLINEAR EP\n\n')
fprintf('  PHYSICAL PROPERTIES\n');
fprintf('  Stiffness                       %6.3f\n', k);
fprintf('  Mass                            %6.3f\n', m);
fprintf('  Damping ratio                   %6.3f\n', xi);
fprintf('  Natural Frequency               %6.3f\n\n', omega);

beta = 0.25; gamma = 0.5;
fprintf('  INTEGRATION OF EQUATIONS\n');
fprintf('  Final time (tf)                 %6.3f\n', tf);
fprintf('  Time increment (h)              %6.3f\n', h);
fprintf('  Numerical integration (beta)    %6.3f\n', beta);
fprintf('  Numerical integration (gamma)   %6.3f\n', gamma);
fprintf('  Number of time steps           %7i\n\n', nSteps);

fprintf('  INITIAL CONDITIONS\n');
fprintf('  Initial position                %6.3f\n', uo);
fprintf('  Initial velocity                %6.3f\n\n', vo);

fprintf('  LOAD FUNCTION\n');
fprintf('  Load name: po*sin(OMEGA*t)      %6.3f\n', uo);
fprintf('  po                              %6.3f\n', 3);
fprintf('  OMEGA                           %6.3f\n\n', 2);
end
