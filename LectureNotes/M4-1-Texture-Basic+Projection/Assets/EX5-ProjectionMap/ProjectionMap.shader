Shader "Unlit/ProjectionMap"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        Cull Off

        Pass 
        {   
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "../CommonShaderCode/CommonDataStruct.cginc"
            
            float4x4 _WorldToProjectionNDC; // from World to the projector's NDC


            v2f vert (appdata v)
            {
                v2f o;
                float4 p = mul(unity_ObjectToWorld, v.vertex);  // objcet to world
                o.worldPos = p.xyz;  // p.w is 1.0 at this poit

                float4 projectionNDC = mul(_WorldToProjectionNDC, p);
                // 
                // o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                //   use this UV
                o.uv = ((projectionNDC.xy / projectionNDC.w) + 1) * 0.5;

                p = mul(UNITY_MATRIX_V, p);  // To view space
                o.vertex = mul(UNITY_MATRIX_P, p);  // Projection 
                            
                o.normal = normalize(mul(v.normal, (float3x3)unity_WorldToObject)); 
                
                return o;
            }            
            
            float4 frag (v2f i) : SV_Target
            {
                // sample the texture
                float4 col = float4(0.9, 0.7, 0.7, 1.0);
                if ((i.uv.x >= 0) && (i.uv.x <= 1) &&
                    (i.uv.y >= 0) && (i.uv.y <= 1) ) {
                    col = tex2D(_MainTex, i.uv) * 1.5;  // boost this texture color to make sure we can see it!
                 }
                float3 L = normalize(_LightPos - i.worldPos);
                float NdotL = max(0.1, dot(i.normal, L)); // don't clam everything off 
                
                return col * NdotL;
            }
           
            ENDCG
        }
    }
}
