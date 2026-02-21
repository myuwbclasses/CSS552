#ifndef SIMPLE_PATCH_CONSTANT_FUNCTION
#define SIMPLE_PATCH_CONSTANT_FUNCTION

float _PatchEdge; // How much to subdivide the triangle edges, range between 1 to 64 (or 0 to 64?)
float _PatchInside; // How much to subdivide the triangle: range about 2^ of

// Patch Constant Function: 
// This function is invoked once per patch, and the input is the control points of the patch (from Hull Shader), 
// and the output is the tessellation factors for this patch, 
// Based on these factors, the actual tessellation will be performed by the GPU 
// (results are in the form of barycentric coordinates of the generated vertices),
// and the results will be passed to the domain shader for interpolation
TessFactor ComputeTessFactor(InputPatch<Vert2Hull, 3> points)
{
    TessFactor o;

    // Strange bug: 
    //   in this function _PatchEdge valus seems to be 0.5 indpendent of what it is set to
    _PatchEdge = _PatchInside + 1;

    o.edges0 = _PatchEdge;   // How much to subdivide the triangle patch, range between 1 to 64 (or 0 to 64?)
    o.edges1 = _PatchEdge+1;  // For some reason _PatchEdge value is always set to 0.5
    o.edges2 = _PatchEdge+2;
    o.inside = _PatchInside;     // This is triangle density, the number of triangles generated is approx (inside)^2
    
    return o;
}

#endif // SIMPLE_PATCH_CONSTANT_FUNCTION