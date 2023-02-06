Shader "Unlit/ColorMask-Control"
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

        // https://docs.unity3d.com/Manual/SL-ColorMask.html
        // Colormask can come here to mask out all passes
        //    Or inside a pass to apply only to that pass
        ColorMask G
            // 0: all off
            // RGBA: any combination to leave them onw
        Pass   // draw x-units away with only R
        {
            ColorMask R  // this overrides the SubShader setting

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "../CommonShaderCode/CommonDataStruct.cginc"
            
            v2f vert (appdata v)
            {
                v2f o; 
                float4 p = v.vertex;  
                p.x += 10;  // only different line
                p = mul(unity_ObjectToWorld, p); 
                o.worldPos = p.xyz;  // p.w is 1.0 at this poit

                p = mul(UNITY_MATRIX_V, p);  // To view space
                o.vertex = mul(UNITY_MATRIX_P, p);  // Projection 
                
                o.normal = normalize(mul(v.normal, (float3x3)unity_WorldToObject)); 
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                return o;
            }
            #include "../CommonShaderCode/CommonFShader.cginc"
            ENDCG
        }

        Pass   // Simple drawing
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "../CommonShaderCode/CommonDataStruct.cginc"
            #include "../CommonShaderCode/CommonVShader.cginc"
            #include "../CommonShaderCode/CommonFShader.cginc"
            
            ENDCG
        }
    }
}
