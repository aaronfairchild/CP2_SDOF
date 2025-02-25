function p = LoadFunction(t,LoadType)
% Compute value

switch LoadType
    case 0
        p = 0;

    case 1
        to = 2;
        po = 1;
        p = 0;
        if t<to
            p = po*sin(pi*t/to);
        end

    case 2
        a = 4; b = 5;
        po = 200;
        p = po*exp(-a*t)-exp(-b*t);

    case 3
        po = 3; OMEGA = 2;
        p = po*sin(OMEGA*t);

    case 4 % just for PoD7
        to = 1; % Duration
        C = 1;
        po = (pi*C)/(2*to);
        OMEGA = pi/to;
        p = 0;
        if t<to
            p = po*sin(OMEGA*t);
        end

end