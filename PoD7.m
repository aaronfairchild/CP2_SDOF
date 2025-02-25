% PoD 7: Pulse Load Time History
% Code by: Aaron Fairchild
% Original: February 5, 2025
% Latest Update: February 25, 2025

function PoD7()
set(0, 'DefaultTextInterpreter', 'latex');
set(0, 'DefaultAxesTickLabelInterpreter', 'latex');
set(0, 'DefaultLegendInterpreter', 'latex');
set(0, 'DefaultAxesFontSize', 14);
set(0, 'DefaultTextFontSize', 14);

%. Physical inputs
m = 1;
c = 0.158;
k = 2.496;
to = 1;
Impulse = 1;
tf = 10;
C = 1;
omega = sqrt(k/m);
xi = c/(2*sqrt(k*m));
wD = omega*sqrt(1-xi^2);

uo = 0;
vo = 0.0;
uoi = uo; voi = vo; % To store

%. Check with Newmark
h = 0.02;
LoadType = 4;
nSteps = ceil(tf/h);
ag = zeros(nSteps, 1); % No earthquake for benchmark

figure('Name','PoD 7'); clf;

d = [1, k, 0, 0];
[U] = Newmark(h,LoadType,m,c,d,tf,uo,vo,ag);
subplot(2,1,1); grid on; hold on;
title('PoD 7: Pulse Load Time History')
ylabel('$u(t)$')
plot(U(:,1),U(:,2), '--k','LineWidth',4)

subplot(2,1,2); grid on; hold on;
ylabel('$v(t)$'); xlabel('$t$');
plot(U(:,1),U(:,3), '--k','LineWidth',4)


OMEGA = pi/to;
po = pi*C/(2*to);
beta = OMEGA/omega;

D = (1-beta^2)^2 + (2*xi*beta)^2;
B1 = uo + (2*xi*beta*po) / (k*D);
B2 = vo/wD + (xi*omega/wD)*(uo + 2*xi*beta*po/(k*D))...
    - ((1-beta^2)*po*OMEGA)/(wD*k*D);

E1 = B2*wD - xi*omega*B1;
E2 = -(B1*wD + xi*omega*B2);

%. Phase I
nPts = 300;
t = linspace(0,to,nPts)';
Cot = cos(wD*t); Sot = sin(wD*t);

u = exp(-xi*omega*t).*(B1*Cot + B2*Sot)...
    + (po/(k*D))*((1-beta^2)*sin(OMEGA*t) - 2*xi*beta*cos(OMEGA*t));

v = exp(-xi*omega*t).*(E1*Cot + E2*Sot)...
    + ((po*OMEGA)/(k*D))*((1-beta^2)*cos(OMEGA*t) + 2*xi*beta*sin(OMEGA*t));

subplot(2,1,1);
plot(t,u,'-','Color','b','LineWidth',2);
plot(t(end),u(end),'ok','MarkerFaceColor','black','MarkerSize',8);


subplot(2,1,2);
plot(t,v,'-','Color','b','LineWidth',2);
plot(t(end),v(end),'ok','MarkerFaceColor','black','MarkerSize',8);


uo = u(end);
vo = (u(end)-u(end-1))/(t(end)-t(end-1));

%. Phase II
t = linspace(to,tf,nPts);
tau = t-to;
A1 = uo;
A2 = (vo + xi*omega*uo)/wD;
u = exp(-xi*omega*tau).*(A1*cos(wD*tau) + A2*sin(wD*tau));
subplot(2,1,1)
plot(t,u,'-','Color','r','LineWidth',2);
F1 = A2*wD - A1*xi*omega;
F2 = -(A1*wD + A2*xi*omega);
v = exp(-xi*omega*tau).*(F1*cos(wD*tau) + F2*sin(wD*tau));
subplot(2,1,2)
plot(t,v,'-','Color','r','LineWidth',2);

subplot(2,1,1);
xline(to, '--k', '$t_o$', 'LineWidth', 2, 'Interpreter','latex', ...
    'FontSize',16,'LabelOrientation','horizontal','LabelVerticalAlignment','bottom');

subplot(2,1,2);
xline(to, '--k', '$t_o$', 'LineWidth', 2, 'Interpreter','latex', ...
    'FontSize',16,'LabelOrientation','horizontal','LabelVerticalAlignment','bottom');



%. Print output
fprintf('PoD 7: Pulse Load Time History\n\n')
fprintf('  PHYSICAL PROPERTIES\n');
fprintf('  Natural Frequency                %6.3f\n', omega);
fprintf('  Frequency ratio (beta)           %6.3f\n', beta);
fprintf('  Damping ratio                    %6.3f\n', xi);
fprintf('  Static displacement (po/k)       %6.3f\n\n', po/k);

fprintf('  Mass                             %6.3f\n', m);
fprintf('  Damping constant                 %6.3f\n', c);
fprintf('  Stiffness                        %6.3f\n', k);
fprintf('  Magnitude of Load (po)           %6.3f\n', po);
fprintf('  Time sine loading ends           %6.3f\n', to);
fprintf('  Driving Frequency                %6.3f\n', OMEGA);
fprintf('  Damped Natural Frequency         %6.3f\n\n', wD);

fprintf('  INITIAL CONDITIONS\n');
fprintf('  Initial displacement (uo)        %6.3f\n', uoi);
fprintf('  Initial velocity (vo)            %6.3f\n\n', voi);
end
