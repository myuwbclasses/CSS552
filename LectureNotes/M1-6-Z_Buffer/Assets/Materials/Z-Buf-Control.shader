Shader "Unlit/Z-Buf-Control"
{
    Properties
    {
        
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        Cull Off
        ZWrite On  // or Off   https://docs.unity3d.com/Manual/SL-ZWrite.html  
                   // When ZWrite is Off, rendering of this object not writing into Z-Buffer
                   // Drawing order is important in this case!
        ZTest Less
            // Modes: Less, LEqual, Equal, GEqual, Greater, NotEqual, Always
            // When would Z-test block  https://docs.unity3d.com/Manual/SL-ZTest.html
            // Default is: Less (if Z-values less than, block!)
        
        // ZClip: only applies to Stencil buffer
        // ZClip True // or False https://docs.unity3d.com/Manual/SL-ZClip.html 

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata { float4 vertex : POSITION; };
            struct v2f { float4 vertex : SV_POSITION; };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                return float4(1, 0, 0, 1);
            }
            ENDCG
        }
    }
}
