function [ptNorm] = splineSmoothNormal(pt, bShow)

if nargin < 2
    bShow = 0;
end

npt = size(pt,1);
if npt < 4
    k = 3;
else
    k = 4;
end

n = max(round(npt/3), k);

R = 0; %k-1;
L = n-k+1; % the number of the picecs of the spline.
MT = L+2*(k-1-R);

T = [zeros(1,R), 0:MT, MT*ones(1,R)]; % knot vectors

dc = pt(2:end, :)-pt(1:end-1, :);
dc = sqrt(sum(dc.*dc,2));
dc = [0; cumsum(dc)];
dc = dc/dc(end);

ux=dc;
sp = spap2(length(T),k,ux,pt');

sp_d = fnder(sp,1);
pt_d = fnval(sp_d,ux)';
ptTang = pt_d./repmat(sqrt(sum(pt_d.^2, 2)), 1,2);
ptNorm = [-ptTang(:,2), ptTang(:,1)];

% 
if bShow
    ptFull = fnval(sp,ux)';    
        
    gap = 1;
    figure;
    hold off;
    plot(pt(:, 1),pt(:, 2),'ko'); hold on;
    plot(pt(:, 1) + ptNorm(:,1)*gap,pt(:, 2) + ptNorm(:,2)*gap,'b.'); hold on;
    plot(ptFull(:, 1),ptFull(:, 2),'r.'); hold on;
    
    axis equal;
    pause;
end
