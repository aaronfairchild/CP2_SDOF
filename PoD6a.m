% PoD 6a: Fitting cruve to data
% Code by: Aaron Fairchild
% Original: February 3, 2025
% Latest Update: February 25, 2025
function PoD6a()

z = PoD6_Data;

figure('Name','PoD 6a'); clf; grid on; hold on;
plot(z(:,1),z(:,2),'ok','LineWidth',0.5,...
     'MarkerFaceColor','k','MarkerEdgeColor','k','MarkerSize',2);

xi = 0.037;
omega = 2.2;
uo = 5;
vo = 0;
tf = 25;
nPts = 300;
[U] = Classical(xi,omega,uo,vo,tf,nPts);
plot(U(:,1),U(:,2),'-','Color','b','LineWidth',2)
end