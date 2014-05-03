#include "mex.h"
#include "graph.cpp"
#include "maxflow.cpp"
#define X(x,y,z,c) (c)*xyzDim+(z)*xyDim+(y)*xDim+x
#define MAX(a,b) (a>b?a:b)


void mexFunction(int			nlhs, 		/* number of expected outputs */
				 mxArray		*plhs[],	/* mxArray output pointer array */
				 int			nrhs, 		/* number of inputs */
				 const mxArray	*prhs[]		/* mxArray input pointer array */)
{     
	double *pDataterm,*pRegPar,*pPar;
	float lambda;
	float fk,fk1;
	float Infinity;
	int xDim,yDim,zDim,cDim;
	int xyDim,xyzDim,xyzcDim;
      int x,y,z,c;
	int i;

	//input:
	pDataterm=mxGetPr(prhs[0]);
	pRegPar=mxGetPr(prhs[1]);
	pPar= mxGetPr(prhs[2]);
      
      lambda=(float) pRegPar[0];
	xDim= (int)pPar[0];
	yDim= (int)pPar[1];
	zDim= (int)pPar[2];
	cDim= (int)pPar[3];
      
	xyDim=xDim*yDim;
	xyzDim=xyDim*zDim;
	xyzcDim=xyzDim*cDim;
	Infinity=10000000000.0f;
//      for (i=0;i<xyzDim;i++)
//	mexPrintf("%d %d %d %d %d %d %d\n",xDim,yDim,zDim,cDim,xyDim,xyzDim,xyzcDim);
   	// create graph
	typedef Graph<float,float,float> GraphType;
	// estimations for number of nodes and edges - we know these exactly!
	GraphType *g = new GraphType(/*estimated # of nodes*/ xyzcDim, /*estimated # of edges*/ 8*xyzcDim);
	
	// add the nodes
	// NOTE: their indices are 0-based
      g->add_node(xyzcDim);
      
      for (c=0;c<cDim;c++)
	 {	
	  for (z=0;z<zDim;z++)
	    for (y=0;y<yDim;y++)
		 for (x=0;x<xDim;x++)
		 { 
	         //t-links: for data term.		 
		   fk=(float) pDataterm[X(x,y,z,c)];
		   fk1=(float) pDataterm[X(x,y,z,c+1)];
               g->add_tweights(X(x,y,z,c),MAX(fk1-fk,0.0f),0.0f);
		   g->add_tweights(X(x,y,z,c),0.0f,MAX(-fk1+fk,0.0f));

		   // super levelset function constraint.
               if (c<cDim-1) 
	  	      g->add_edge(X(x,y,z,c),X(x,y,z,c+1),Infinity,0.0f);
		   
               //n-links: for Regularization term
		   if (x<xDim-1)
		   {
		       g->add_tweights(X(x+1,y,z,c),MAX(lambda/2.0f,0.0f),0.0f);
			 g->add_tweights(X(x+1,y,z,c),0.0f,MAX(-lambda/2.0f,0.0f));          
			 g->add_tweights(X(x,y,z,c),MAX(-lambda/2.0f,0.0f),0.0f);
			 g->add_tweights(X(x,y,z,c),0.0f,MAX(lambda/2.0f,0.0f));
                   g->add_edge(X(x+1,y,z,c),X(x,y,z,c),lambda,0.0f);

		   
		   }

		   if (x>0)
		   {
		       g->add_tweights(X(x-1,y,z,c),MAX(lambda/2.0f,0.0f),0.0f);
			 g->add_tweights(X(x-1,y,z,c),0.0f,MAX(-lambda/2.0f,0.0f));          
			 g->add_tweights(X(x,y,z,c),MAX(-lambda/2.0f,0.0f),0.0f);
			 g->add_tweights(X(x,y,z,c),0.0f,MAX(lambda/2.0f,0.0f));
                   g->add_edge(X(x-1,y,z,c),X(x,y,z,c),lambda,0.0f);

		   
		   }

		   if (y<yDim-1)
		   {
		       g->add_tweights(X(x,y+1,z,c),MAX(lambda/2.0f,0.0f),0.0f);
			 g->add_tweights(X(x,y+1,z,c),0.0f,MAX(-lambda/2.0f,0.0f));          
			 g->add_tweights(X(x,y,z,c),MAX(-lambda/2.0f,0.0f),0.0f);
			 g->add_tweights(X(x,y,z,c),0.0f,MAX(lambda/2.0f,0.0f));
                   g->add_edge(X(x,y+1,z,c),X(x,y,z,c),lambda,0.0f);

		   
		   }

		     if (y>0)
		   {
		       g->add_tweights(X(x,y-1,z,c),MAX(lambda/2.0f,0.0f),0.0f);
			 g->add_tweights(X(x,y-1,z,c),0.0f,MAX(-lambda/2.0f,0.0f));          
			 g->add_tweights(X(x,y,z,c),MAX(-lambda/2.0f,0.0f),0.0f);
			 g->add_tweights(X(x,y,z,c),0.0f,MAX(lambda/2.0f,0.0f));
                   g->add_edge(X(x,y-1,z,c),X(x,y,z,c),lambda,0.0f);

		   
		   }


     

		   

		   //n-links: for regularization term.
	/*	   
		   if (x<xDim-1)
		    {	   
		       g->add_tweights(X(x+1,y,z,c),MAX(-lambda,0.0f),0.0f);
			 g->add_tweights(X(x+1,y,z,c),0.0f,MAX(lambda,0.0f));
                 

		    }
		    else
		    {
		       g->add_tweights(X(x,y,z,c),MAX(-lambda,0.0f),0.0f);
			 g->add_tweights(X(x,y,z,c),0.0f,MAX(lambda,0.0f));
		    
		    }
		    if (y<yDim-1)
		    {	   
		       g->add_tweights(X(x,y+1,z,c),MAX(-lambda,0.0f),0.0f);
			 g->add_tweights(X(x,y+1,z,c),0.0f,MAX(lambda,0.0f));


		    }
		    else
		    {
		       g->add_tweights(X(x,y,z,c),MAX(-lambda,0.0f),0.0f);
			 g->add_tweights(X(x,y,z,c),0.0f,MAX(lambda,0.0f));

		    
		    }

		   g->add_tweights(X(x,y,z,c),MAX(2.0f*lambda,0.0f),0.0f);
		   g->add_tweights(X(x,y,z,c),0.0f,MAX(-2.0f*lambda,0.0f));

		 if (x<xDim-1)
		   g->add_edge(X(x,y,z,c),X(x+1,y,z,c),2.0f*lambda,0.0f);
		 if (y<yDim-1)
		   g->add_edge(X(x,y,z,c),X(x,y+1,z,c),2.0f*lambda,0.0f);
		   */

             /*
		   
		   if (x<xDim-1)
		    {	 
		         g->add_tweights(X(x+1,y,z,c),MAX(-2.0f*lambda,0.0f),0.0f);
			   g->add_tweights(X(x+1,y,z,c),0.0f,MAX(2.0f*lambda,0.0f));
                   

		    }
		    else
		    {
			 
		         g->add_tweights(X(x,y,z,c),MAX(-2.0f*lambda,0.0f),0.0f);
			   g->add_tweights(X(x,y,z,c),0.0f,MAX(2.0f*lambda,0.0f));
			 
		    }

                if (y<yDim-1)
		    {	 
			   g->add_tweights(X(x,y+1,z,c),MAX(-2.0f*lambda,0.0f),0.0f);
			   g->add_tweights(X(x,y+1,z,c),0.0f,MAX(2.0f*lambda,0.0f));
                   
		    }
		    else
		    {
			   g->add_tweights(X(x,y,z,c),MAX(-2.0f*lambda,0.0f),0.0f);
			   g->add_tweights(X(x,y,z,c),0.0f,MAX(2.0f*lambda,0.0f));
			 
		    }

		    g->add_tweights(X(x,y,z,c),MAX(4.0f*lambda,0.0f),0.0f);
		    g->add_tweights(X(x,y,z,c),0.0f,MAX(-4.0f*lambda,0.0f));
		    
		    
                
		    if (x<xDim-1)
		     {
		        g->add_edge(X(x,y,z,c),X(x+1,y,z,c),4.0f*lambda,0.0f);
			  
		     }
		    if (y<yDim-1) 
		    {	 
			    
		       g->add_edge(X(x,y,z,c),X(x,y+1,z,c),4.0f*lambda,0.0f);
	
		    }

               */  
            
		   
		  /* //It seems wrong!!!!!! 
               if (x<xDim-1)
		    {	 
		         g->add_tweights(X(x+1,y,z,c),MAX(-4.0f*lambda,0.0f),0.0f);
			   g->add_tweights(X(x+1,y,z,c),0.0f,MAX(4.0f*lambda,0.0f));
                   

		    }
		    else
		    {
			 
		         g->add_tweights(X(x,y,z,c),MAX(-4.0f*lambda,0.0f),0.0f);
			   g->add_tweights(X(x,y,z,c),0.0f,MAX(4.0f*lambda,0.0f));
			 
		    }

                if (y<yDim-1)
		    {	 
			   g->add_tweights(X(x,y+1,z,c),MAX(-4.0f*lambda,0.0f),0.0f);
			   g->add_tweights(X(x,y+1,z,c),0.0f,MAX(4.0f*lambda,0.0f));
                   
		    }
		    else
		    {
			   g->add_tweights(X(x,y,z,c),MAX(-4.0f*lambda,0.0f),0.0f);
			   g->add_tweights(X(x,y,z,c),0.0f,MAX(4.0f*lambda,0.0f));
			 
		    }


		    		    
                
		    if (x<xDim-1)
		     {
		        g->add_edge(X(x,y,z,c),X(x+1,y,z,c),4.0f*lambda,0.0f);
			  
		     }
		    if (y<yDim-1) 
		    {	 
			    
		       g->add_edge(X(x,y,z,c),X(x,y+1,z,c),4.0f*lambda,0.0f);
	
		    }	    

		    if (x<xDim-1)
		    {
		       if(c<cDim-1)
                   g->add_edge(X(x+1,y,z,c+1),X(x+1,y,z,c),2.0f*lambda,0.0f);
                   if (c==0)
			 {
			   g->add_tweights(X(x+1,y,z,c),MAX(-2.0f*lambda,0.0f),0.0f);
			   g->add_tweights(X(x+1,y,z,c),0.0f,MAX(2.0f*lambda,0.0f));

			 }
			 if(c==cDim-1)
			 {
			   g->add_tweights(X(x+1,y,z,c),MAX(2.0f*lambda,0.0f),0.0f);
			   g->add_tweights(X(x+1,y,z,c),0.0f,MAX(-2.0f*lambda,0.0f));
	 
			 }
		       
		      
		    }

		    if (y<yDim-1)
		    {
		       if (c<cDim-1)
                   g->add_edge(X(x,y+1,z,c+1),X(x,y+1,z,c),2.0f*lambda,0.0f);
                   if (c==0)
			 {
			   g->add_tweights(X(x,y+1,z,c),MAX(-2.0f*lambda,0.0f),0.0f);
			   g->add_tweights(X(x,y+1,z,c),0.0f,MAX(2.0f*lambda,0.0f));

			 }
			 if(c==cDim-1)
			 {
			   g->add_tweights(X(x,y+1,z,c),MAX(2.0f*lambda,0.0f),0.0f);
			   g->add_tweights(X(x,y+1,z,c),0.0f,MAX(-2.0f*lambda,0.0f));
	 
			 }
		       
		      
		    }

                if(c<cDim-1)
                   g->add_edge(X(x,y,z,c+1),X(x,y,z,c),4.0f*lambda,0.0f);
                if (c==0)
			 {
			   g->add_tweights(X(x,y,z,c),MAX(-4.0f*lambda,0.0f),0.0f);
			   g->add_tweights(X(x,y,z,c),0.0f,MAX(4.0f*lambda,0.0f));

			 }
			 if(c==cDim-1)
			 {
			   g->add_tweights(X(x,y,z,c),MAX(4.0f*lambda,0.0f),0.0f);
			   g->add_tweights(X(x,y,z,c),0.0f,MAX(-4.0f*lambda,0.0f));
	 
			 }

*/


              

		   
		 }
	 }



	plhs[0] = mxCreateDoubleMatrix(1,1,mxREAL);
	double* flow = mxGetPr(plhs[0]);
	*flow = (double) g->maxflow();
//      mexPrintf("%f\n",g->maxflow());

	// figure out segmentation
	plhs[1] = mxCreateNumericMatrix(xyzcDim,1,mxINT32_CLASS, mxREAL);
	int* labels = (int*)mxGetPr(plhs[1]);
	for (i = 0; i < xyzcDim; i++)
	{
		labels[i] = g->what_segment(i);
	}

	// cleanup
	delete g;
    
	
}

