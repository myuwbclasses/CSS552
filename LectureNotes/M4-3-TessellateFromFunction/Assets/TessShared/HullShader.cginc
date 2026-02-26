#ifndef HULL_SHADER
#define HULL_SHADER

float _HullOffsetAmount; // How much to subdivide the triangle patch, range between 1 to 64 (or 0 to 64?)

// The [] denotes the attributes of the shader stage function
//
// Hull Shader
[domain("tri")]  // What is the input/output from Domain: tri, quad, isoline
    // tri: domain shader is invoked for each triangle patch, and the input patch is always 3 control points
    // quad: domain shader is invoked for each quad patch, and the input patch is always 4 control points
    // isoline: domain shader is invoked for each isoline patch, and the input patch is always 2 control points

[partitioning("integer")] // subdivision mode along the edge: fractional_odd, fractional_even, integer, pow2
    // Integer: each edge is subdivided into a whole number of segments, 
    //      independent of the other edges. 
    //      This is the most common subdivision mode.
    // Pow2: each edge is subdivided into a power-of-two number of segments, independent of the other edges.    
    // Odd: each edge is always subdivided into an odd number of segments, 
    //      so that the middle vertex is always on the edge midpoint. 
    // Even: each edge is always subdivided into an even number of segments, 
    //      so that no vertex is generated on the edge midpoint. 
    
[outputtopology("triangle_cw")]  // Triangle output ordering: not optional!
    // Options: triangle_cw, triangle_ccw, line_adjacency, point

[patchconstantfunc("ComputeTessFactor")] // Patch constant function
    // Function name for computing the TessFactor based on a input triangle (or patch)

[outputcontrolpoints(3)] // Number of control points to emit by the hull shader
    // Typically 3 for tri domain, 4 for quad domain
    

// The Hull shader is invoked for each control point in the input patch, 
// and the output is the control point information to be used by the domain shader
// Note: input 3-control Points, and return is just 1 of the control points
// So the job of the Hull Shder is to compute the control point information 
// based on the input, the results will be used for interpolating the tessellation 
// results in the domain shader
OutputFromHull Hull(InputPatch<Vert2Hull, 3> points, 
                        uint id : SV_OutputControlPointID) // Which vertex of the 3-point patch is this control point shader invoked for
{                
    // For now, let's not do anything
    OutputFromHull o; 

    o.pcPos = points[id].pcPos; // 
    o.ocPos = points[id].ocPos;
    o.ocNormal = points[id].ocNormal;

    o.color = points[id].color;
    o.uv = points[id].uv;

    // Examine: Displace the positions of the triangles, or, 
    // compute the area of the triangle, etc.

    return o;
}

#endif // HULL_SHADER