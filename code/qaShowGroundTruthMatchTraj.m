frm1 = annoContourFrmInfo(showContourIdx,1);
frm2 = annoContourFrmInfo(showContourIdx,2);
numContourFrm = frm2 - frm1 + 1;
numTick = size(annoContourTrk{showContourIdx},1);

frmMat = repmat(1:numContourFrm, numTick, 1);

figure;
mesh(annoContourTrk{showContourIdx}(:,:,1), annoContourTrk{showContourIdx}(:,:,2), frmMat, 'LineWidth', 3);
hold on;

idx = find(showTickFrmMchTrk<0);

trkNoVec = unique(-showTickFrmMchTrk(idx));
trkNoVec = trkNoVec';

for trkNo = trkNoVec
    trkFrm1 = max(frm1, cfTrackInfo(trkNo,1));
    trkFrm2 = min(frm2, cfTrackInfo(trkNo,2));

    frmVec = trkFrm1:trkFrm2;
    
    px = [];
    py = [];
    pz = [];
    for it_f = frmVec
        pt = cfTrackData{trkNo}(it_f-cfTrackInfo(trkNo,1) + 1,:);
        px(end+1,:) = pt(1);
        py(end+1,:) = pt(2);
        pz(end+1,:) = (it_f - frm1 + 1);
    end
    plot3(px, py, pz, 'k', 'LineWidth', 2);
end
axis equal;


