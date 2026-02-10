Shader"Custom/PC_Screen_GS"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma geometry geom       // <-- This is NEW!
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2g
            {
                float4 pos : POSITION;  // Transform to PC
            };

            struct g2f
            {
                float4 pos : SV_POSITION;
            };

            // output all informaiton in OC for geometric shader to perform simple subdivision
            v2g vert(appdata v)
            {
                v2g o;
                o.pos =  UnityObjectToClipPos(v.vertex); // in PC, for rasterization
                return o;
            }

            [maxvertexcount(6)]  // is this max number of vertices that geom can generate
            void geom(triangle v2g input[3], inout TriangleStream<g2f> triStream)
            {
                // VERY elementary screen-space subdivision
                //   1. Find the longest screen space edge, 
                //   2. Divide the edge into two, and 
                //   3. Create two triangles. 
                // Does not do anything to UV, Color, normal etc. etc.
                //       
                float2 e0 = input[1].pos.xy - input[0].pos.xy;
                float2 e1 = input[2].pos.xy - input[1].pos.xy;
                float2 e2 = input[0].pos.xy - input[2].pos.xy;
                float l0 = length(e0);
                float l1 = length(e1);
                float l2 = length(e2);

                g2f quad[4];  // will have 4 verticds
                for (int i = 0; i < 3; i++)  // first three are the same as the input triangle
                    quad[i].pos = input[i].pos;

                // Find the longest edge
                if (l0 > l1 && l0 > l2) {
                    // edge 0 is the longest, divide it
                    quad[3].pos = input[0].pos + 0.5 * (input[1].pos - input[0].pos);
                    // The two triangles are then: 032 and 123
                    triStream.Append(quad[0]);
                    triStream.Append(quad[3]);
                    triStream.Append(quad[2]);
                    triStream.RestartStrip();
                    triStream.Append(quad[1]);
                    triStream.Append(quad[2]);
                    triStream.Append(quad[3]);
                    triStream.RestartStrip();
                }
                else if (l1 > l2)
                {
                    // edge 1 is the longest, divide it
                    quad[3].pos = input[1].pos + 0.5 * (input[2].pos - input[1].pos);
                    // The two triangles are then: 013 and 032
                    triStream.Append(quad[0]);
                    triStream.Append(quad[1]);
                    triStream.Append(quad[3]);
                    triStream.RestartStrip();
                    triStream.Append(quad[0]);
                    triStream.Append(quad[3]);
                    triStream.Append(quad[2]);
                    triStream.RestartStrip();
                }
                else
                {
                    // edge 2 is the longest, divide it
                    quad[3].pos = input[2].pos + 0.5 * (input[0].pos - input[2].pos);
                    // The two triangles are then: 013 and 123
                    triStream.Append(quad[0]);
                    triStream.Append(quad[1]);
                    triStream.Append(quad[3]);
                    triStream.RestartStrip();
                    triStream.Append(quad[1]);
                    triStream.Append(quad[2]);
                    triStream.Append(quad[3]);
                    triStream.RestartStrip();
                }
            }
            sampler2D _MainTex;

            float4 frag(g2f i) : SV_Target
            {
                return float4(0.7, 0.6, 0.6, 1.0);
            }
            ENDCG
        }
    }
}
