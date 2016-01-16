1. Directories
=================================================
+---code: code for the visualization and evaluation.<br>
+---frames: the image sequences in the dataset.<br>
+---groundTruth: the annotated motion of some contours.<br>
+---results/contourFlow: the contour flow estimated by our method.<br>
>>>>>>>>>>>>>>>>>>>>>>>> In each mat file, "contourPair" is the frame-by-frame contour flow,<br> 
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"cfTrackData" is the long-term trajectories obtained by concatenating the contour flow,<br>
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"cfTrackInfo" is the start and end frame for each trajectory.<br>

2. Instructions
=================================================
1) open matlab, navigate to the directory "code".<br>
2) run "mex_complie".<br>
3) run "anno_showResults" to visualize the groundthruth.<br>
4) run "cf_showResults" to visualize the contour flow estimated by our method.<br>
5) run "qa_compareResult" to find the matching between the groundtruth and the contour flow, and run "qa_statResult" to plot the coverage against the error threshold.
