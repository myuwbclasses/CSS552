Shader "Unlit/EX1_Shader"
{
    Properties
    {
        _Offset("Offset in OC", Vector) = (0, 0, 0)
        _ShowInOC("Show in OC", Integer) = 0  // 0 shows in WC, 1 shows in OC
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
                
                #include "P1-DrawOriginal.cginc"
            
                ENDHLSL
        }

       Pass
        {
            HLSLPROGRAM
                #pragma vertex vert
                #pragma fragment frag

                #include "P2-DrawAtOffset.cginc"
            ENDHLSL
        }
    }
}
