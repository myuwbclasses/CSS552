Shader "Unlit/CheckerTexture"
{
    Properties
    {
        _Color1 ("Color-1", Color) = (0, 0, 0, 1)
        _Color2 ("Color-2", Color) = (1, 1, 1, 1)
        _URepeat("U Repeat", Float) = 2
        _VRepeat("V Repeat", Float) = 2
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
            float _URepeat;
            float _VRepeat;

            // when repeat is (1, 1), transitions occur at 1
            // when repeat is (2, 2), transitions occur at 0.5
            //                (3, 3)                       0.33
            // we will count how many transitions should occur
            // work in integer space is easier, so we multiply
            // if u/v  odd/even returns c1/c2
            float4 frag(v2f i) : SV_TARGET { 
                float2 uv = float2(i.uv.x*_URepeat, i.uv.y*_VRepeat);
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
