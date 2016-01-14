function imOrgSeq = data_loadImageSeq(myRoot, st, iSeq)

imNameSeq = {};
for i=1:st.dataInfo{iSeq}{2}
    imNameSeq{i} = sprintf(['frames/' st.dataInfo{iSeq}{1} '/%04d.png'], i);
end

imOrgSeq = {};
for i=1:st.dataInfo{iSeq}{2}
    imOrgSeq{i} = imread([myRoot '/' imNameSeq{i}]);
end
