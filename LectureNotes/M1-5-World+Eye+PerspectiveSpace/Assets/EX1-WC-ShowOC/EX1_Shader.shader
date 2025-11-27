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
            #pragma vertex vert
            #pragma fragment frag
                #include "P1-DrawInWC.cginc"
            ENDHLSL
        }

       Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
                #include "P2-DrawInOC.cginc"
            ENDHLSL
        }
    }
}
