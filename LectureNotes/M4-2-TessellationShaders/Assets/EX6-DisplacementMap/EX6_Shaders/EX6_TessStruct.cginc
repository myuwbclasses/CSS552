#ifndef EX6_TESS_STRUCT
#define EX6_TESS_STRUCT

// for EX6 Specifically

// From Applicaiton to Vertex Shader
struct appdata  {
    float4 vertex : POSITION; // leave in OC space
    float3 normal : NORMAL; // Object space normal
    float2 uv : TEXCOORD0;
    float2 uv1 : TEXCOORD1;
    float4 color : TEXCOORD2; // Vertex color
};

// From Vertex Shader to Hull Shader:
struct Vert2Hull {
    float4 pcPos : SV_POSITION; // Clip space position  // This must be there!
    float3 ocPos : TEXCOORD0; // Vertex position in Object space, for convenience
    float3 ocNormal : NORMAL; //  normal in OC space
    float3 wcNormal: TEXCOORD1; // World space normal
    float2 uv : TEXCOORD2;
    float4 color : TEXCOORD3; // Vertex color
};

// Note: this strucutre is exactly the same as Vert2Hull
//       It is used to pass information from Hull shader to Domain shader
//       By giving these structuers different names, we can carefully examine
//       the order upon which shaders are invoked in the GPU
struct OutputFromHull {
    float4 pcPos : SV_POSITION; // Clip space position  // This must be there!
    float3 ocPos : TEXCOORD0; // Vertex position in Object space, for convenience
    float3 ocNormal : NORMAL; //  normal in OC space

    float2 uv : TEXCOORD1;
    float4 color : TEXCOORD2; // Vertex color
};

// This structure, for a triangle is FIXED, 
// the number of edges is fixed, and the inside is also fixed,
struct TessFactor {
    // float edges[3] : SV_TessFactor;      // how many times an edge will subdivide: range between 1 to 64 (or 0 to 64?)
            // Either as an array with SV_TessFactor semantic, 
            // Or    as individual variables with SV_TessFactor0, SV_TessFactor1, SV_TessFactor2 semantics,
    float edges0 : SV_TessFactor0;     
    float edges1 : SV_TessFactor1;     
    float edges2 : SV_TessFactor2;     
        // The edges are HARD-Coded to related to the vertices!! BE careful!!
        // edges[0]: is V[1] to V[2]
        // edges[1]: is V[0] to V[2]
        // edges[2]: is V[0] to V[1]
    float inside : SV_InsideTessFactor; // approx: (inside)^2 is approx number of times a new triangle will be created
};

struct Domain2Geom {
    float4 pcPos : SV_POSITION; // Clip space position
    float3 ocPos : TEXCOORD0; // World space position
    float3 ocNormal : NORMAL; // World space normal
    float2 uv : TEXCOORD1;
    float4 color : TEXCOORD2; // Vertex color
};


// By the time we invoke the Frament shader, only the shading parameters
// are needed, so we can define a more optimized structure
struct Geom2Frag {
    float4 pcPos : SV_POSITION; // Clip space position
    float3 wcPos : TEXCOORD0; // World space position
    float3 wcNormal : NORMAL; // World space normal
    float2 uv : TEXCOORD1;
    float4 color : TEXCOORD2; // Vertex color
};

#endif // EX6_TESS_STRUCT