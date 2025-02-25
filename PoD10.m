% PoD 10: Nonlinear elasticity
% Code by: Aaron Fairchild
% Original: February 17, 2025
% Latest Update: February 24, 2025
function PoD10()

set(0, 'DefaultTextInterpreter', 'latex');
set(0, 'DefaultAxesTickLabelInterpreter', 'latex');
set(0, 'DefaultLegendInterpreter', 'latex');
set(0, 'DefaultAxesFontSize', 14);
set(0, 'DefaultTextFontSize', 14);

% Input physical parameters
k = 16;
m = 1;
xi = 0.03;
b = 1;

omega = sqrt(k/m);
c = 2*xi*omega*m;

LoadType = 0;  % No load

uo = 3.0;
vo = 5.0;
tf = 3.9;
h = 0.01;

nSteps = ceil(tf/h);
ag = zeros(nSteps, 1); % No earthquake for benchmark

% Linear Elastic
ModelType = 1;
So = 0; % not doing yielding stuff
d = [ModelType, k, b, So];
[U_LElastic] = Newmark(h,LoadType,m,c,d,tf,uo,vo,ag);

% Non-Linear Stiffening
ModelType = 2;
d = [ModelType, k, b, So];
[U_NLStiff] = Newmark(h,LoadType,m,c,d,tf,uo,vo,ag);

% Non-Linear Softening
ModelType = 3;
d = [ModelType, k, b, So];       % [Model type, k, b, So]
[U_NLSoft] = Newmark(h,LoadType,m,c,d,tf,uo,vo,ag);


% Plot
figure('Name','PoD 10 Benchmark'); clf;
figsize = [0,0.4,0.4,0.6];
set(gcf, 'Units','normalized','OuterPosition', figsize)

% Non-Linear Stiffening and Linear Elastic
% Responses vs. Time
subplot(2,2,1); grid on; hold on;
plot(U_NLStiff(:,1),U_NLStiff(:,2),'b-','LineWidth',2)
plot(U_LElastic(:,1),U_LElastic(:,2),'k:','LineWidth',1)
xlabel('$t$'); ylabel('$u(t)$')
legendText = {'Nonlinear Stiffening', 'Linear Elastic'};
legend(legendText, 'Location', 'best', 'Interpreter', 'latex');
title('Response vs. Time')

% Force vs. Displacement
subplot(2,2,2); grid on; hold on;
plot(U_NLStiff(:,2),U_NLStiff(:,5),'k-','LineWidth',2)
xlabel('$u(t)$'); ylabel('$r$')
title('Force vs. Displacement')

% Non-Linear Softening and Linear Elastic

% Responses vs. Time
subplot(2,2,3); grid on; hold on;
plot(U_NLSoft(:,1),U_NLSoft(:,2),'r-','LineWidth',2)
plot(U_LElastic(:,1),U_LElastic(:,2),'k:','LineWidth',1)
xlabel('$t$'); ylabel('$u(t)$')
legendText = {'Nonlinear Softening', 'Linear Elastic'};
legend(legendText, 'Location', 'best', 'Interpreter', 'latex');
title('Response vs. Time')

% Force vs. Displacement
subplot(2,2,4); grid on; hold on;
plot(U_NLSoft(:,2),U_NLSoft(:,5),'k-','LineWidth',2)
xlabel('$u(t)$'); ylabel('$r$')
title('Force vs. Displacement')

% Print output
fprintf('PoD 10: SDOF Nonlinear elastic vibration\n\n')
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
end