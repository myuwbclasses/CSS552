Shader "Unlit/Mirror"
{
    // Main camera draws
    // To be replaced by MyReflection == Mirror
    // in MirrorCam
    Properties
    {
        
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue" = "Geometry-1" "MyReflection" = "Mirror"}
        LOD 100
        Cull Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
            };


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return float4(0, 0, 0, 0);
                    // Rendered by the MainCam
                    // alpha MUST BE zero, indicating this pixel is "empty" 
                    // empty for objects and for MirrorCam to draw mirrored objects into
            }
            ENDCG
        }
    }
}
