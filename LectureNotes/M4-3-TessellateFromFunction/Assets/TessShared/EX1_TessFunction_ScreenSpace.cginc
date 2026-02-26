#ifndef EX1_TESS_FUNCTION
#define EX1_TESS_FUNCTION


float _EdgeLength; // Desired edge length of triangle in pixels 
float _EdgesPerPeroidOC; // how many edges we want in a peroid (2Pi)
        // Recall, each 2-pi in X/Z is defined by _XPerPeriodOC and _ZPerPeriodOC, 
        // By observation, it seems 5 to 10 edges is fine per pi/2, or, 20 to 40 edge per 2pi.
        // So, in OC space, we want to have an edge every _XPerPeriodOC/_EdgePerPeroidOC or _ZPerPeriodOC/_EdgePerPeroidOC
        // So, number of edges in OC space is 
        //   Dist = distance in OC space between two vertices 
        //   numEdges = _EdgePerPeroidOC * Dist / _XPerPeriodOC 

#define TO_NDC(p) ((((p).xyz / (p).w) + 1) * 0.5)  // Convert from clip space to NDC

#define LEN_IN_SCREEN(e)  (length(e.xy * float2(_ScreenWidth, _ScreenHeight))) // from NDC space to screen space
        // ScreenWidth and ScreenHeight are in pixels, defined in TessControlFlags.cginc

// Patch constant function: compute tessellation factors based on edge length in screen space
// Vert.vetex is in PC space (-1 o 1) range. We will
//    1. Divide by w to get NDC space, and
//    2. +1 and * 0.5 to convert to 0-1 range, and then
//    3. Multiply by screen resolution to get pixel space, and compute edge length in pixel space.
TessFactor ComputeTessFactor(InputPatch<Vert2Hull, 3> points)
{
    TessFactor o = (TessFactor)1;
    
    if (ModeIsSet(kApplyScreenSpace)) {    
        // Size of the edges
        // MUST Conform to what the hardware expects!
        // If you mixed up edge[index] and points[index]: shared vertex between 
        //     triangles will be subdivided differently, which will cause cracks in the mesh!
        //
        // edges[0]: is index 1 and 2
        float3 e = TO_NDC(points[1].pcPos) - TO_NDC(points[2].pcPos);
        o.edges0 = LEN_IN_SCREEN(e) / _EdgeLength;

        // edges[1]: is index 0 and 2
        e = TO_NDC(points[0].pcPos) - TO_NDC(points[2].pcPos);
        o.edges1 = LEN_IN_SCREEN(e) / _EdgeLength;

        // edges[2]: is index 0 and 1
        e = TO_NDC(points[0].pcPos) - TO_NDC(points[1].pcPos);
        o.edges2 = LEN_IN_SCREEN(e) / _EdgeLength;
    }
    
    o.inside = (0.3 * (o.edges0 + o.edges1 + o.edges2)); // Heuristic for inside tessellation factor, almost average of edge subdivide
    return o;
}

#endif // EX1_TESS_FUNCTION