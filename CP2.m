%-----------------------------------------------------------------------
%   CP 2 - SDOF
%
%     Author:  Aaron Fairchild
%     Date:    February 27, 2025
%-----------------------------------------------------------------------
tic; clear; clc; 
delete(findall(0, 'Type', 'figure')); % gets rid of all open figures
set(0, 'DefaultTextInterpreter', 'latex');
set(0, 'DefaultAxesTickLabelInterpreter', 'latex');
set(0, 'DefaultLegendInterpreter', 'latex');

doPoDs = false; % Run the PoD Benchmark cases? (true/false)

if doPoDs
    % Run PoD6 (a and b), with benchmark parameters
    PoD6a();
    PoD6b();

    % Run PoD7, with benchmark parameters
    PoD7();

    % Run PoD8( a and b), with benchmark parameters
    PoD8a();
    PoD8b();

    % Run PoD9, with benchmark parameters
    PoD9();

    % Run PoD10, with benchmark parameters
    PoD10();

    % Run PoD11, with benchmark parameters
    PoD11();
end



elapsedTime = toc; 
fprintf(['Elapsed time since start: %.2f seconds.\n' ...
         'Normal Termination of Program.\n'], elapsedTime);