#ifndef VERT_SHADER
#define VERT_SHADER

// Vertex Shader
// Computes every thing under the sun that we can think of
Vert2Hull Vert(appdata v)
{
    Vert2Hull o;
    
    o.pcPos = UnityObjectToClipPos(v.vertex); // Compute clip space position in the vertex shader

    // For OC computations to be performed
    o.ocPos = v.vertex.xyz; // Object space position, for convenience
    o.ocNormal = v.normal; // normal in OC space
    o.ocTangent = v.tangent; // tangent in OC space

    o.uv = v.uv; // TRANSFORM_TEX(v.uv, _MainTex);
    o.color = v.color;

    return o;
}

#endif // VERT_SHADER