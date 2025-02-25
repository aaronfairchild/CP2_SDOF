function [r, dr, iv] = ConstModel(u,d,iv)
% Compute force r given displacement u and
% iv, plastic strain (internal variable)

ModelType = d(1);

switch ModelType
    case 1 % Linear Elastic
        k = d(2);
        r = k*u;
        dr = k;

    case 2 % Nonlinear stiffening model
        k = d(2); b = d(3);
        r = k*u*(1 + b*u^2);
        dr = k*(1 + 3*b*u^2);

    case 3 % Nonlinear softening model
        k = d(2); b = d(3);
        r = k*u/sqrt(1 + b*u^2);
        dr = k/(1 + b*u^2)^(3/2);

    case 4 % Elastoplastic model
        k = d(2); So = d(4);
        r = k*(u-iv);
        dr = k;
        if abs(r) > So
            r = So*sign(r);
            dr = 0;
            iv = u - r/k;
        end
end

end