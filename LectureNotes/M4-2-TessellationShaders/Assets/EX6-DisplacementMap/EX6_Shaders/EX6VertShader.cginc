#ifndef EX6_VERT
#define EX6_VERT

// Vertex Shader
// Computes every thing under the sun that we can think of
Vert2Hull EX6Vert(appdata v)
{
    Vert2Hull o;
    
    o.pcPos = UnityObjectToClipPos(v.vertex); // Compute clip space position in the vertex shader

    // For OC computations to be performed
    o.ocPos = v.vertex.xyz; // Object space position, for convenience
    o.ocNormal = v.normal; // normal in OC space

    o.uv = v.uv; // TRANSFORM_TEX(v.uv, _MainTex);
    o.color = v.color;

    return o;
}

#endif // EX6_VERT