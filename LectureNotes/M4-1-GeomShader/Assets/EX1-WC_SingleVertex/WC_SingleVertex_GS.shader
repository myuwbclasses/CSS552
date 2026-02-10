Shader"Custom/WC_SingleVertex_GS"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Size ("Square Size", Range(0.2, 2.0)) = 0.2
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        // Cull Off
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma geometry geom
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2g
            {
                float4 wcPos : POSITION;  // In WC Space
                float2 uv : TEXCOORD0;
                float3 wcNormal : NORMAL; 
            };

            struct g2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            float _Size;

            // output all informaiton in OC for geometric shader to perform simple subdivision
            v2g vert(appdata v)
            {
                v2g o;
                o.wcPos = mul(unity_ObjectToWorld, v.vertex); //  WC
                o.uv = v.uv;
                o.wcNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject)); // in WC
                return o;
            }

            // point: input primitive type, triangle strip, line strip, ...
            // If this is attached to a Triangle Primtive, only the frist vertex will be used as input
            // Compute a small square at the vertex in the X/Y plane
            [maxvertexcount(4)]  // is this max number of vertices that geom can generate
            void geom(point v2g input[1], inout TriangleStream<g2f> triStream)  // can we do wihout the []? Probably not
            {
                g2f quad[4];
                // Define 4 corners of the quad (bottom-left, top-left, bottom-right, top-right)
                // This defines two triangles: (0, 1, 2) and (1, 2, 3)
                quad[0].pos = input[0].wcPos + float4(-_Size,  -_Size, 0, 0);
                quad[1].pos = input[0].wcPos + float4(-_Size,   _Size, 0, 0);
                quad[2].pos = input[0].wcPos + float4( _Size,  -_Size, 0, 0);
                quad[3].pos = input[0].wcPos + float4( _Size,   _Size, 0, 0);
                
                // remember input is in WC, so the quad is also in WC, we need to transform it to clip space for rasterization
                for (int i = 0; i < 4; i++)
                    quad[i].pos = mul(UNITY_MATRIX_VP, quad[i].pos); // to clip space

                // since the WC-X/Y plane is not transformed, 
                // wc normal is (0, 0, 1) for all vertices of the quad
                for (int i = 0; i < 4; i++)
                    quad[i].normal =  float3(0, 0, 1); // Normal of the X/Y plane in WC

                // UVs for the quad: complete coverage of the texture
                quad[0].uv = float2(0, 0);
                quad[1].uv = float2(0, 1);
                quad[2].uv = float2(1, 0);
                quad[3].uv = float2(1, 1);
                
                for (int i=0; i < 4; i++)
                    triStream.Append(quad[i]);
                
                triStream.RestartStrip(); // if we want to start a new strip, we need to call this 
                                          // to avoid connecting the last vertex of previous strip with the first vertex of new strip
            }
            sampler2D _MainTex;

            float4 frag(g2f i) : SV_Target
            {
                return tex2D(_MainTex, i.uv);
            }
            ENDCG
        }
    }
}
