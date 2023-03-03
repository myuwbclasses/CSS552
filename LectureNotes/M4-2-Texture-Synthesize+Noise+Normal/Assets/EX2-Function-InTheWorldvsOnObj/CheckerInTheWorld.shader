Shader "Unlit/CheckerInWorld"
{
    Properties
    {
        _Color1 ("Color-1", Color) = (0, 0, 0, 1)
        _Color2 ("Color-2", Color) = (1, 1, 1, 1)
        _USize("U Size", Float) = 1.0
        _VSize("V Size", Float) = 1.0
    }
    
    SubShader
    {
        Tags { "RenderType"="Opaque"}
        LOD 100
        // Cull Off

        Pass 
        {   
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "../CommonShaderCode/CommonDataStruct.cginc"
            #include "../CommonShaderCode/CommonVShader.cginc"

            float4 _Color1;
            float4 _Color2;
            float _USize;
            float _VSize;

            // Map x/z to UV
            float4 frag(v2f i) : SV_TARGET { 
                float2 uv = float2(i.worldPos.x / _USize, i.worldPos.z / _VSize);
                float2 uvi = trunc(uv);  // integer
                if ((uvi.x%2) == (uvi.y%2))
                    return _Color1;
                else 
                    return _Color2;
            }
           
            ENDCG
        }
    }
}
