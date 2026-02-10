v2f vert (appdata v)
{
    v2f o;
    float4 p = mul(unity_ObjectToWorld, v.vertex);  // objcet to world
    o.worldPos = p.xyz;  // p.w is 1.0 at this poit

    p = mul(UNITY_MATRIX_V, p);  // To view space
    o.vertex = mul(UNITY_MATRIX_P, p);  // Projection 
                
    o.normal = normalize(mul(v.normal, (float3x3)unity_WorldToObject)); 
    o.uv = v.uv;
    return o;
}