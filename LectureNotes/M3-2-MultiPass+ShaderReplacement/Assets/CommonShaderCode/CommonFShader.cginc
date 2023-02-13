
float4 frag (v2f i) : SV_Target
{
    // sample the texture
    float4 col = float4(0.9, 0.7, 0.7, 1.0);
    if ((i.uv.x != 0) && (i.uv.y != 0))
        col = tex2D(_MainTex, i.uv);
    float3 L = normalize(_LightPos - i.worldPos);
    float NdotL = max(0.1, dot(i.normal, L)); // don't clam everything off 
    return col * NdotL;
}