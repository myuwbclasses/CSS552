Shader "Unlit/StrangeSine"
{
    Properties
    {
        _CenterX ("Center X", Range(-2, 2)) = 0.5
        _CenterY ("Center Y", Range(-2, 2)) = 0.5
        _Frequency("Frequency", float) = 2
        _Color1 ("Color 1", Color) = (0, 0, 0, 1)
        _Color2 ("Color 2", Color) = (1, 1, 1, 1)
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
            float _CenterX;
            float _CenterY;
            float _Frequency;

            float4 frag(v2f i) : SV_TARGET { 
                float d = length(i.uv - float2(_CenterX, _CenterY));
                float v = sin(d * _Frequency * 2 * 3.14 );
                return v * _Color1 + (1-v) * _Color2;
            }
            ENDCG
        }
    }
}
