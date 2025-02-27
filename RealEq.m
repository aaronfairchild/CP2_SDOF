% Aaron Fairchild
function [t,ag] = RealEq() % could maybe add filename input later

filename = 'RSN740_LOMAP_ADL340.AT2';

% Open the file
fid = fopen(filename, 'r');

% Skip the first three lines
for i = 1:3
    fgetl(fid);
end

% Read the fourth line to get NPTS and DT
line = fgetl(fid);
tokens = regexp(line, 'NPTS=\s*(\d+),\s*DT=\s*([\d.]+)', 'tokens');
NPTS = str2double(tokens{1}{1});
DT = str2double(tokens{1}{2});

% Read acceleration values
data = fscanf(fid, '%f');

% Close the file
fclose(fid);

% Generate time vector
t = (0:NPTS-1)' * DT;

% Assign acceleration vector
ag = data;
end