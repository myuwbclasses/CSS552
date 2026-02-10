Shader"Custom/WC_Billboard_GS"
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
        Cull Back
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
            float3 _MainCameraPos;

            // output all informaiton in OC for geometric shader to perform simple subdivision
            v2g vert(appdata v)
            {
                v2g o;
                o.wcPos = mul(unity_ObjectToWorld, v.vertex); //  WC
                o.uv = v.uv;
                o.wcNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject)); ; // in WC
                return o;
            }

            // This should be parameter, but, we want to avoid passing an array
            

            void StreamQuadInDir(float3 viewDir, float4 centerPos, inout TriangleStream<g2f> triStream)
            {
                float3 right = normalize(cross(float3(0, 1, 0), viewDir)) * _Size;
                                // Assuming viewDir is not parallel to the up vector (0, 1, 0). 
                                //In practice, we should check this and use a different up vector if they are parallel
                float3 up = normalize(cross(viewDir, right)) * _Size;

                g2f quad[4];
                // Define 4 corners of the quad (bottom-left, top-left, bottom-right, top-right)
                quad[0].pos = mul(UNITY_MATRIX_VP, centerPos + float4(-right - up, 0));
                quad[1].pos = mul(UNITY_MATRIX_VP, centerPos + float4(-right + up, 0));
                quad[2].pos = mul(UNITY_MATRIX_VP, centerPos + float4( right - up, 0));
                quad[3].pos = mul(UNITY_MATRIX_VP, centerPos + float4( right + up, 0));
                

                quad[0].uv = float2(0, 0);
                quad[1].uv = float2(0, 1);
                quad[2].uv = float2(1, 0);
                quad[3].uv = float2(1, 1);
                
                for (int i = 0; i < 4; i++)
                    quad[i].normal = viewDir; // for now

                for (int i=0; i < 4; i++) 
                    triStream.Append(quad[i]);
                triStream.RestartStrip(); // if we want to start a new strip, we need to call this 
                                          // to avoid connecting the last vertex of previous strip with the first vertex of new strip
            }

            // Compute a small square at the vertex to be perpendicular to the view direction
            [maxvertexcount(12)]  // 4 vertices for each vertrex
            void geom(triangle v2g input[3], inout TriangleStream<g2f> triStream)  
            {
                for (int i = 0; i < 3; i++) {
                    float4 centerPos = input[i].wcPos; // in WC
                    float3 viewDir = normalize(centerPos.xyz - _MainCameraPos);
                    StreamQuadInDir(viewDir, centerPos, triStream);
                }
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
