
DataForFragmentShader VertexProgram(DataFromVertex input)
{
    DataForFragmentShader output;
    
    float4 p = mul(unity_ObjectToWorld, input.vertex);  // objcet to world
    output.worldPos = p.xyz;  // p.w is 1.0 at this poit
    p = mul(UNITY_MATRIX_V, p);  // To view space
    output.vertex = mul(UNITY_MATRIX_P, p);  // Projection 
    
    output.normal = normalize(mul(input.normal, (float3x3)unity_WorldToObject));  // if scaled and ignore translation
            // Transpose of Inversed(unity_ObjectToWorld)
    output.uv = input.uv;
    return output;
}

float4 FragmentProgram(DataForFragmentShader input) : SV_Target
{
    return PhongWithLights(input);
}
