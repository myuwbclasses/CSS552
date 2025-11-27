Shader "Unlit/EX1_Shader"
{
    Properties
    {
        _ShowFlag("Show: 0(None) 1(WC) 2(OC)", Integer) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
                #include "P1-DrawInWC.cginc"
            ENDHLSL
        }

       Pass
        {
            HLSLPROGRAM
                #include "P2-DrawInOC.cginc"
            ENDHLSL
        }
    }
}
