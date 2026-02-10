Shader"Custom/OC_DivideWithN_GS"
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
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 color: COLOR; // we will use vertex color to verify the barycentric coordinate
            };

            struct v2g
            {
                float4 pos : POSITION;  // All in OC space, including normal
                float2 uv : TEXCOORD0;
                float3 objNormal : NORMAL; 
                float4 color : COLOR; // pass the vertex color to geom shader for visualization
            };

            struct g2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 wcPos : TEXCOORD1; // in WC, for lighting calculation in frag shader
                float3 normal : NORMAL;
                float4 color : COLOR; // pass the vertex color to frag shader for visualization
            };

            uint _Flag;
            float _NormalOffset;  // amount to offset the center along the normal direction, in OC space
            float _CenterOffset;  // where to put the center point, in OC space. The center will be offseted by (CenterOffset, 0, CenterOffset) in OC space.
            float3 _LightPos;

            #define ModeIsSet(flag) ((_Flag & flag) != 0)

            static const uint kComputeNothing = 0x01;
            static const uint kComputeDivide = 0x02;

            static const uint kShowShadedTexture = 0x01 << 10;
            static const uint kShowUV = 0x01 << 11;
            static const uint kShowWCPos = 0x01 << 12;
            static const uint kShowNormal = 0x01 << 13;
            static const uint kShowLightDir = 0x01 << 14;
            static const uint kShowNdotL = 0x01 << 15;
            static const uint kShowVertexColor = 0x01 << 16;
            static const uint kShowUnshadedTexture = 0x01 << 17;

            static const uint kUseDirectionalLight = 0x01 << 20;
            static const uint kUsePointLight = 0x01 << 21;

            // output all informaiton in OC for geometric shader to perform simple subdivision
            v2g vert(appdata v)
            {
                v2g o;
                o.pos = v.vertex; // leave in OC
                o.uv = v.uv;
                o.objNormal = v.normal; // in OC
                o.color = v.color; // pass the vertex color to geom shader for visualization
                return o;
            }

            [maxvertexcount(9)]  // is this max number of vertices that geom can generate
            void geom(triangle v2g input[3], inout TriangleStream<g2f> triStream)
            {
                // in OC: capture the center of the triangle, and normal of the triangle
                float4 center = (input[0].pos + input[1].pos + input[2].pos) / 3.0;
                float3 normal = (input[0].objNormal + input[1].objNormal + input[2].objNormal) / 3.0;
                center += float4(_CenterOffset, 0, _CenterOffset, 0); // offset the center in X/Z OC space
                center += _NormalOffset * float4(normal, 0); // offset the center along the normal direction
                    // The above operation must be performed in OC, because the normal is in OC. 
                    
                g2f quad[4];
                for (int i = 0; i < 3; i++)
                {
                    float4 v = input[i].pos; // 
                    quad[i].pos = UnityObjectToClipPos(v);
                    quad[i].uv = input[i].uv;
                    quad[i].wcPos = mul(unity_ObjectToWorld, v).xyz; // in WC, for lighting calculation in frag shader
                    quad[i].normal = normalize(mul(input[i].objNormal, (float3x3)unity_WorldToObject)); // in WC
                    quad[i].color = input[i].color; // pass the vertex color to frag shader for visualization
                }
                    
                if (ModeIsSet(kComputeNothing)) { // show center point as a small quad
                    triStream.Append(quad[0]);
                    triStream.Append(quad[1]);
                    triStream.Append(quad[2]);
                    triStream.RestartStrip();
                } else { 
                    quad[3].pos = UnityObjectToClipPos(center);
                    quad[3].wcPos = mul(unity_ObjectToWorld, center).xyz; // convert to WC for lighting computation in frag shader
                    quad[3].uv = (input[0].uv + input[1].uv + input[2].uv) / 3.0; 
                    quad[3].color = (input[0].color + input[1].color + input[2].color) / 3.0;
                                // This are NOT correct, tolerate for now
                    // Perfomm subdivision
                    // Must re-comppute the normals for each vertex
                    //
                    // Remember, normal computation must be done in WC!!

                    // For Triangle 0, 1, 3
                    float3 e1 = quad[1].wcPos - quad[0].wcPos;
                    float3 e2 = quad[3].wcPos - quad[0].wcPos;
                    float3 tn_013 = normalize(cross(e1, e2));

                    // For Triangle 3, 1, 2
                    e1 = quad[2].wcPos - quad[1].wcPos;
                    e2 = quad[3].wcPos - quad[1].wcPos;
                    float3 tn_312 = normalize(cross(e1, e2));

                    // For Triangle 0, 3, 2
                    e1 = quad[0].wcPos - quad[2].wcPos; 
                    e2 = quad[3].wcPos - quad[2].wcPos;
                    float3 tn_032 = normalize(cross(e1, e2));

                    quad[3].normal = normalize(tn_013 + tn_312 + tn_032); // this vertex touches all three triangles

                    quad[0].normal = normalize(tn_013 + tn_032); // this vertex touches triangle 013 and 203
                    quad[1].normal = normalize(tn_013 + tn_312); // this vertex touches triangle 013 and 123
                    quad[2].normal = normalize(tn_312 + tn_032); // this vertex touches triangle 123 and 203

                    triStream.Append(quad[0]);
                    triStream.Append(quad[1]);
                    triStream.Append(quad[3]);
                    triStream.RestartStrip();

                    triStream.Append(quad[3]);
                    triStream.Append(quad[1]);
                    triStream.Append(quad[2]);
                    triStream.RestartStrip();

                    triStream.Append(quad[0]);
                    triStream.Append(quad[3]);
                    triStream.Append(quad[2]);
                    triStream.RestartStrip();
                }
            }
            sampler2D _MainTex;

            float4 frag(g2f i) : SV_Target
            {
                // directional light direction
                float3 lightDir = normalize(_LightPos - i.wcPos); // in WC, and point light
                if (ModeIsSet(kUseDirectionalLight)) {
                    lightDir = normalize(_LightPos); // in WC, and directional light
                }
                // conpute diffuse
                float diff = max(dot(i.normal, lightDir), 0.0);
                float4 texColor = tex2D(_MainTex, i.uv);
                if (ModeIsSet(kShowShadedTexture))
                    return texColor * diff;
                if (ModeIsSet(kShowUV))
                    return float4(i.uv, 0.0, 1.0);
                if (ModeIsSet(kShowWCPos))
                    return float4(i.wcPos, 1.0);
                if (ModeIsSet(kShowNormal))
                    return float4(i.normal, 1.0);
                if (ModeIsSet(kShowLightDir))
                    return float4(lightDir, 1.0);
                if (ModeIsSet(kShowNdotL))
                    return float4(diff, diff, diff, 1.0);
                if (ModeIsSet(kShowVertexColor))
                    return i.color;
                if (ModeIsSet(kShowUnshadedTexture))
                    return texColor;
                
                return float4(1.0, 0.0, 0.0, 1.0); // What is going on?
            }
            ENDCG
        }
    }
}
