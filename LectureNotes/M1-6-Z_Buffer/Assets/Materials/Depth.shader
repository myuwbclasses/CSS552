Shader "Unlit/Depth"
{
    Properties
    {
        
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        Cull Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata { float4 vertex : POSITION; };

            struct v2f {
                float4 vertex : SV_POSITION;
                float dist : TEXCOORD0;  // distance in NDC space
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.dist = o.vertex.z / o.vertex.w; // distance
                // by default, the closer the larger the value, furthest is zero
                    // this distance is from the camera to the object
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float d = (i.dist * 5);  // some boost so we can see the colors

                if (d > 1.0f)
                    return float4(0, 0, 1, 1);
                if (d < 0.0f)
                    return float4(0, 1, 1, 1);

                return float4(d, d, d, 1);
            }
            ENDCG
        }
    }
}
