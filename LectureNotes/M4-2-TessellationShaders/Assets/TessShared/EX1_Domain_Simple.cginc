#ifndef SIMPLE_DOMAIN
#define SIMPLE_DOMAIN

// Domain Shader
[domain("tri")] // Input is a triangle
// Our job is to compute the Information to be passed to Fragment shader
Domain2Frag SimpleDomain(TessFactor i, // Results from the ComputeTessFactor function
        const OutputPatch<OutputFromHull, 3> cp, // Control points from the Hull shader
        float3 bary : SV_DomainLocation) // Barycentric coordinates of the generated vertex
{
    Domain2Frag o;

    // Use barycentric to interpolate all vertex data
    o.uv = BCInterpolate(cp[0].uv, cp[1].uv, cp[2].uv, bary);
    o.uv1 = BCInterpolate(cp[0].uv1, cp[1].uv1, cp[2].uv1, bary);
    o.color = BCInterpolate(cp[0].color, cp[1].color, cp[2].color, bary);
    
    o.pcPos = BCInterpolate(cp[0].pcPos, cp[1].pcPos, cp[2].pcPos, bary);
    o.wcPos = BCInterpolate(cp[0].wcPos, cp[1].wcPos, cp[2].wcPos, bary);
    o.ocPos = BCInterpolate(cp[0].ocPos, cp[1].ocPos, cp[2].ocPos, bary);
    o.wcNormal = BCInterpolate(cp[0].wcNormal, cp[1].wcNormal, cp[2].wcNormal, bary);
    
    return o;
}

#endif // SIMPLE_DOMAIN