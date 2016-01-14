#include "mex.h"
#include<math.h>
#include<memory.h>

#define min(a,b)    (((a) < (b)) ? (a) : (b))
#define max(a,b)    (((a) > (b)) ? (a) : (b))

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{    
	// mchMat = calcOverlappedLenTraj(annoContourTrk{ic}, annoContourFrmInfo(ic,:), trkFrmInfo, trajTracks, distTh);
	if (nrhs < 6){
		mexPrintf("wrong input arguments for calcOverlappedLenTraj.\n");
		return;
	}
    if (nlhs < 1){
        mexPrintf("wrong output arguments for calcOverlappedLenTraj.\n");
        return;
    }

	//  create a pointer to the input matrix y
    double *annoContourTrk, *ptr, *trkFrmInfo, distTh, distThNormal;
	const mxArray *trajTracks, *pData, *trajTrackData;
	int numTick, numTrack, frm1, frm2, n;
	

	annoContourTrk = mxGetPr(prhs[0]);
    numTick = mxGetM(prhs[0]);

	ptr = mxGetPr(prhs[1]);
	frm1 = int(ptr[0] + 0.5);
	frm2 = int(ptr[1] + 0.5);
    
	trkFrmInfo = mxGetPr(prhs[2]);
	numTrack = mxGetM(prhs[2]);

	trajTracks = prhs[3];
	distTh = mxGetScalar(prhs[4]);
	distThNormal = mxGetScalar(prhs[5]);

	int * mchMat, *mchFrm0, *mchFrm1, *trkStartIdxVec;
	int *tickFrmMchTrk, iTickHead;
	int iMaxTrkNo;
	int iTrk, iTick, iFrm, trkFrm1, trkFrm2, k;
	int startFrm, contourStartIdx, trkStartIdx, frmNum;
	int numTrkPoint, overNum, iTrkPt, maxOverNum, off, contourYOff, contourNormXOff, contourNormYOff;

	double *trkPtX, *trkPtY;
	double trkX, trkY, contourX, contourY, dx, dy, dist, distNorm, normX, normY;
	int overFrmBegin, overFrmEnd, maxOverFrmBegin, maxOverFrmEnd, numContourFrame, myTrkPt;

	numContourFrame = frm2-frm1+1;
	n = numTick*numTrack;
    mchMat = new int [n*3 + numTrack + numTick*numContourFrame];    
    if (0 == mchMat){
        mexPrintf("mem @calcOverlappedLenTraj.\n");
        return;        
    }
	mchFrm0 = mchMat + n;
	mchFrm1 = mchFrm0 + n;
	trkStartIdxVec = mchFrm1 + n;
	tickFrmMchTrk = trkStartIdxVec + numTrack;

	memset(mchMat, 0, n*sizeof(int));
	memset(tickFrmMchTrk, 0, numTick*numContourFrame*sizeof(int));
    
	contourYOff = numTick*numContourFrame;
	contourNormXOff = 2*numTick*numContourFrame;
	contourNormYOff = 3*numTick*numContourFrame;

	// for each track, find its maximum overlap with each groundtruth traj (each iTick)
	for (k=iTrk=0; iTrk<numTrack; iTrk++, k+=numTick){
		trkFrm1 = int(trkFrmInfo[iTrk] + 0.5);
		trkFrm2 = int(trkFrmInfo[iTrk + numTrack] + 0.5);

		if ( (frm1 > trkFrm2) || (frm2 < trkFrm1) ) continue;
		// overlapped
		trajTrackData = mxGetCell(trajTracks, iTrk);
		numTrkPoint = mxGetM(trajTrackData);
		trkPtX = (double *)mxGetPr(trajTrackData);
		trkPtY = trkPtX + numTrkPoint;

		if (frm1>=trkFrm1){
			startFrm = frm1-1; // to zero-based
			contourStartIdx = 0;
			trkStartIdx = frm1 - trkFrm1;
		}else{
			startFrm = trkFrm1-1; // to zero-based
			contourStartIdx = trkFrm1-frm1;
			trkStartIdx = 0;
		}
		frmNum = min(frm2, trkFrm2) - startFrm;

		trkStartIdxVec[iTrk] = trkStartIdx;
				
		for (iTick=0; iTick<numTick; iTick++){
			maxOverNum = 0;
			overNum = 0;
			overFrmBegin = overFrmEnd = 0;
			for (iFrm=0; iFrm<frmNum; iFrm++){
				// annoContourTrk(tick,frm,1)
				off = iTick + (iFrm+contourStartIdx)*numTick;
				contourX = annoContourTrk[off];
				contourY = annoContourTrk[off + contourYOff];
				normX = annoContourTrk[off + contourNormXOff];
				normY = annoContourTrk[off + contourNormYOff];

				iTrkPt = iFrm+trkStartIdx;
				trkX = trkPtX[iTrkPt];
				trkY = trkPtY[iTrkPt];

				dx = contourX-trkX;
				dy = contourY-trkY;

				distNorm = dx*normX + dy*normY;
				distNorm = abs(distNorm);

				dist = sqrt(dx*dx + dy*dy - distNorm*distNorm);

				if (dist <= distTh && distNorm <= distThNormal){
					if (overNum == 0) overFrmBegin = iFrm;
					overNum++;
					overFrmEnd = iFrm;
				}else{
					if (overNum > maxOverNum){
						maxOverNum = overNum;
						maxOverFrmBegin = overFrmBegin;
						maxOverFrmEnd = overFrmEnd;
					}
					overNum = 0;
				}
			} // iFrm
			if (overNum > maxOverNum){
				maxOverNum = overNum;
				maxOverFrmBegin = overFrmBegin;
				maxOverFrmEnd = overFrmEnd;
			}
			
			if (maxOverNum > 1){
				mchMat[k + iTick] = maxOverNum;
				mchFrm0[k + iTick] = maxOverFrmBegin + contourStartIdx;
				mchFrm1[k + iTick] = maxOverFrmEnd + contourStartIdx;
			}
		} // iTick
	} // iTrk

	// for each groundtruth traj (each iTick), find its most(and second most, ...)-overlapped tracks
	for (iTickHead=iTick=0; iTick<numTick; iTick++, iTickHead+=numContourFrame){
		while(1){
			// find max
			maxOverNum = 0;
			k = iTick;
			for (iTrk=0; iTrk<numTrack; iTrk++, k+=numTick){
				overNum = mchMat[k];
				if (overNum > maxOverNum){
					maxOverNum = overNum;
					iMaxTrkNo = iTrk;
				}
			}
			if (maxOverNum <= 1) break;

			// store
			k = iMaxTrkNo*numTick + iTick;
			frm1 = mchFrm0[k];
			frm2 = mchFrm1[k];
			tickFrmMchTrk[iTickHead + frm1] = maxOverNum;
			for (iFrm=frm1+1; iFrm<=frm2; iFrm++){
				tickFrmMchTrk[iTickHead + iFrm] = -(iMaxTrkNo + 1);
			}

			// clear overlap
			k = iTick;
			for (iTrk=0; iTrk<numTrack; iTrk++, k+=numTick){
				if (mchMat[k] == 0) continue;

				if (mchFrm0[k] < frm1){
					mchFrm1[k] = min(frm1-1, mchFrm1[k]);
				}else{
					mchFrm0[k] = max(frm2+1, mchFrm0[k]);
				}
				overNum = mchFrm1[k] - mchFrm0[k] + 1;

				if (overNum > 0){
					mchMat[k] = overNum;
				}else{
					mchFrm1[k] = mchFrm0[k];
					mchMat[k] = 0;
				}
			}
		}
	}

	// output
    plhs[0] = mxCreateNumericMatrix(numContourFrame, numTick, mxINT32_CLASS, mxREAL);

	n = numTick*numContourFrame;
	int *outptr;
	
	outptr = (int *)mxGetPr(plhs[0]);
	for (k=0; k<n; k++) outptr[k] = tickFrmMchTrk[k];

	delete mchMat;
}
