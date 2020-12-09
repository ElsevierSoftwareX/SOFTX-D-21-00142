// PNPOLY, written by W. Rudolph Franklin and found at
// http://www.ecse.rpi.edu/Homepages/wrf/Research/Short_Notes/pnpoly.html
// Transferred to mex by Patrik Malm, patrik@cb.uu.se
// 
// 	Inputs are:
// 		Number of points in the polygon
//	    Polygon X-coordinates
//	    Polygon Y-coordinates
//	    Point X-coordinate
//	    Point Y-coordinate
//
//	Output:
//		Boolean - inside = 1

#include "mex.h"
#include <math.h>
#include <vector>

void mexFunction(int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[]) {

	double *nverttmp = (double*) mxGetPr(prhs[0]);
	double *vertx = (double*) mxGetPr(prhs[1]);
	double *verty = (double*) mxGetPr(prhs[2]);
	double *testxtmp = (double*) mxGetPr(prhs[3]);
	double *testytmp = (double*) mxGetPr(prhs[4]);
	
	int nvert = (int)nverttmp[0];
	double testx = testxtmp[0];
	double testy = testytmp[0];
	int i, j, c = 0;

	for (i = 0, j = nvert-1; i < nvert; j = i++) {
	if ( ((verty[i]>testy) != (verty[j]>testy)) &&
	 (testx < (vertx[j]-vertx[i]) * (testy-verty[i]) / (verty[j]-verty[i]) + vertx[i]) )
	   c = !c;
	}
	
	plhs[0] = mxCreateNumericMatrix(1, 1, mxDOUBLE_CLASS,mxREAL);
	double *resultOut; 
	resultOut = (double*) mxGetPr(plhs[0]);
	
	resultOut[0] = (double)c;

}