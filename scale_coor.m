function Cel = scale_coor(Cel, n)
%A function for finding the 2D coordinates of MEEG sensors

% check limits and stretch, if possible
dx = max(Cel(1,:)) - min(Cel(1,:));
dy = max(Cel(2,:)) - min(Cel(2,:));

if dx > 1 || dy > 1
    error('Coordinates not between 0 and 1');
end

scale = (1 - 10^(-6))/max(dx, dy);
Cel(1,:) = n*scale*(Cel(1,:) - min(Cel(1,:)) + eps) + 0.5;
Cel(2,:) = n*scale*(Cel(2,:) - min(Cel(2,:)) + eps) + 0.5;

% shift to middle
dx = n+0.5 -n*eps - max(Cel(1,:));
dy = n+0.5 -n*eps - max(Cel(2,:));
Cel(1,:) = Cel(1,:) + dx/2;
Cel(2,:) = Cel(2,:) + dy/2;

% 2D coordinates in voxel-space (incl. badchannels)
Cel = round(Cel)';

end

