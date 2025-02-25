function [U] = Classical(xi,omega,uo,vo,tf,nPts)
% Compute the classical solution to test problem 
%      a + 2*xi*omega*v + omega^2*u = 0

%. Initialize storage array
   U = zeros(nPts,4);
   
%. Compute constants   
   wD = omega*sqrt(1-xi^2);
   C1 = uo;
   C2 = (vo + xi*omega*uo)/wD;
   E1 = wD*C2 - xi*omega*C1;
   E2 = -(wD*C1 + xi*omega*C2);
   F1 = wD*E2 - xi*omega*E1;
   F2 = -(wD*E1 + xi*omega*E2);
   
%. Compute velocity and acceleration
   t = linspace(0,tf,nPts)';
   e = exp(-xi*omega*t);
   Cot = cos(wD*t); Sot = sin(wD*t);
   U(:,1) = t;
   U(:,2) = e.*(C1*Cot + C2*Sot);   % Displacement u(t)
   U(:,3) = e.*(E1*Cot + E2*Sot);   % Velocity v(t)
   U(:,4) = e.*(F1*Cot + F2*Sot);   % Acceleration a(t) 

end