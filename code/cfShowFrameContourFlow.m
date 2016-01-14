showPairChainWidth = 1.5;
cmap = jet(16);
cmap = cmap([1:end],:);
cmap = vertcat(cmap,flipud(cmap));
numColor = size(cmap, 1);

nFrame = length(imOrgSeq);
for it_f=1:nFrame-1
    
    imPrev = imOrgSeq{it_f};
    imCur = imOrgSeq{it_f+1};
    
    numChain = size(contourPair{it_f}, 1);
    
    pickContour = 0;
    [pairChain1, pairChain2] = genPairChainStruct(contourPair{it_f});
    
    [II, JJ] = ndgrid(1:numChain, 1:numChain);
    idx = find(II > JJ);
    II = II(idx);
    JJ = JJ(idx);
    
    numPair = length(II);
    
    dw = ones(numPair, 1);
    for i = 1:numPair
        ti = II(i);
        tk = JJ(i);
        
        pt1 = contourPair{it_f}{ti}(:,1:2);
        pt2 = contourPair{it_f}{tk}(:,1:2);
        
        n1 = size(pt1, 1);
        n2 = size(pt2, 1);
        
        dx = repmat(pt1(:,1), 1, n2) - repmat(pt2(:,1)', n1, 1);
        dy = repmat(pt1(:,2), 1, n2) - repmat(pt2(:,2)', n1, 1);
        
        dist = (dx.*dx + dy.*dy);
        dw(i) = sqrt(min(dist(:)));
    end
    cfConn = sparse(II(:), JJ(:), dw, numChain, numChain);
    [nodeOrder, treeLayer, nodeParent, nodeWeight] = mstNodeOrdering(cfConn);
    
    sy = size(imPrev, 1);
    sx = size(imPrev, 2);
    mask = zeros(sy, sx);
    
    figure(1);
    clf;
    
    subplot(121);
    imshow(imPrev);
    hold on;
    
    for it_ch=1:numChain
        pt = round(contourPair{it_f}{it_ch}(:,1:2));
        if isempty(pt)
            continue;
        end
        idx = (pt(:,1)-1)*sy + pt(:,2);
        mask(idx) = 0;
        
        if size(pt, 1) < 10
            continue;
        end
        
        plot(pt(:,1), pt(:,2), '-', 'Color', cmap(mod(nodeOrder(it_ch), numColor)+1, :), 'lineWidth', showPairChainWidth); hold on;
    end
    
    for it_ch=1:numChain
        pt = contourPair{it_f}{it_ch}(:,1:2);
        if isempty(pt)
            continue;
        end
        if size(pt, 1) < 10
            continue;
        end
        
        
        plot(pt([1 end],1), pt([1 end],2), 'o', 'Color', cmap(mod(nodeOrder(it_ch), numColor)+1, :), 'lineWidth', 1.5, 'MarkerSize', 2); hold on;
    end
    
    if pickContour
        [x, y] = ginput(1);
        pt = [x, y];
        [chNo, ptNo] = findNearestChain(pairChain1, pt, 10);
        chNo
        pt = round(contourPair{it_f}{chNo}(:,1:2));
        plot(pt(:,1), pt(:,2), '-', 'Color', cmap(cidx(it_ch), :), 'lineWidth', 3); hold on;
    end
    
    title(num2str(it_f));
    
    %%
    subplot(122);
    imshow(imCur);
    hold on;
    
    for it_ch=1:numChain
        pt = contourPair{it_f}{it_ch}(:,3:4);
        if isempty(pt)
            continue;
        end
        if size(pt, 1) < 10
            continue;
        end
        plot(pt(:,1), pt(:,2),  '-', 'Color', cmap(mod(nodeOrder(it_ch), numColor)+1, :), 'lineWidth', showPairChainWidth); hold on;
    end
    
    for it_ch=1:numChain
        pt = contourPair{it_f}{it_ch}(:,3:4);
        if isempty(pt)
            continue;
        end
        if size(pt, 1) < 10
            continue;
        end
        plot(pt([1 end],1), pt([1 end],2), 'o', 'Color', cmap(mod(nodeOrder(it_ch), numColor)+1, :), 'lineWidth', 1.5, 'MarkerSize', 2); hold on;
    end
    title(num2str(it_f+1));
    drawnow;
    
    print('-dbmp', '-r240',sprintf('%s/contour_%s%03d.bmp', gl_tmpRoot, gl_dataSetting.dataInfo{gl_iSeq}{1}, it_f));
end

