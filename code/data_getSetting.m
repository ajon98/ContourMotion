function [ st ] = data_getSetting()

st = struct;
st.dataInfo = {  
                 {'bvds_ballet', 87},
                 {'bvds_animal_chase', 60},
                 {'bvds_capoeira', 121},
                 {'bvds_frozen_lake', 121},
                 {'ut_hit', 45},
                 {'ut_hug', 60},
                 {'ut_kick', 62},
                 {'ut_push', 62},
                 {'pose_chandler', 70},
                 {'pose_man', 30},
                 {'pose_rachel', 60},
                 {'pose_rose', 80}
              };
st.numSeq = length(st.dataInfo);

end
               