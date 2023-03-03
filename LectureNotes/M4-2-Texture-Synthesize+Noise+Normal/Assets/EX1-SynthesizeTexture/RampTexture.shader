Shader "Unlit/RampTexture"
{
    Properties
    {
        _Color1 ("Color-1", Color) = (0, 0, 0, 1)
        _Color2 ("Color-2", Color) = (1, 1, 1, 1)
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
            
            float4 frag(v2f i) : SV_TARGET { 
                return i.uv.x * _Color1 + i.uv.y * _Color2;
            }
            ENDCG
        }
    }
}
