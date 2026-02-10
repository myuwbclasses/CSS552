Shader"Custom/OC_Barycentric_GS"
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
            float _NormalOffset;
            float _CenterOffset;
            float _Alpha1;
            float _Alpha2; 
            float3 _LightPos;

            #define ModeIsSet(flag) ((_Flag & flag) != 0)

            static const uint kComputeNothing = 0x01;
            static const uint kComputeDivide = 0x02;

            static const uint kUseSimpleAverage = 0x01 << 4; // use the center offset to compute the center point in GS
            static const uint kUseBCAlphas = 0x01 << 5; // use the alpha1 and alpha2 as the barycentric coordinate to compute the center point in GS

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
                // Now, use barycentric coordinate and ignore the CenterOffset ... 
                float a0 = 1.0 - _Alpha1 - _Alpha2;
                float4 center = a0 * input[0].pos + _Alpha1 * input[1].pos + _Alpha2 * input[2].pos;

                // for normal uv, and color, let's use our computed barycentric coordinate to do interpolation, instead of simple averaging
                float a1, a2;
                if (ModeIsSet(kUseSimpleAverage)) {
                    a0 = a1 = a2 = 1.0 / 3.0; // simple average
                } else {
                    // actual barycentric coordinate can be computed in OC or WC
                    // for simplicity, let's do it in OC
                    float3 pv0 = center.xyz - input[0].pos.xyz;
                    float3 pv1 = center.xyz - input[1].pos.xyz;
                    float3 pv2 = center.xyz - input[2].pos.xyz;
                    float3 v01 = input[1].pos.xyz - input[0].pos.xyz;
                    float3 v02 = input[2].pos.xyz - input[0].pos.xyz;
                    float area_2 = length(cross(v01, v02));
                    a0 = length(cross(pv1, pv2)) / area_2;
                    a1 = length(cross(pv0, pv2)) / area_2;
                    a2 = 1.0 - a0 - a1;
                }
                // center's y-offset can only be applied _AFTER_ benrycentric coordinate is computed
                // this is because the offset will throw off the barycentric coordinate computation
                // the assumption that the three subdivided triangles are all flat no longer holds
                // if the sum of the three areas do not sum to the original triangle area, 
                // the barycentric coordinate computation will be wrong
                center += _NormalOffset * float4(input[0].objNormal, 0); 
                    // A flat triangle, all three vertex normals are the same
                
                // now, compute average at center
                float3 normal = a0 * input[0].objNormal + a1 * input[1].objNormal + a2 * input[2].objNormal;
                float4 color =  a0 * input[0].color     + a1 * input[1].color     + a2 * input[2].color;
                float2 uv =     a0 * input[0].uv        + a1 * input[1].uv        + a2 * input[2].uv;
                                    
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
                    quad[3].uv = uv;
                    quad[3].color = color; // pass the vertex color to frag shader for visualization
                                
                    // Perfomm subdivision
                    // Must re-comppute the normals for each vertex//
                    // Remember, normal computation must be done in WC!!

                    // For Triangle 0, 1, 3
                    float3 e1 = quad[1].wcPos - quad[0].wcPos;
                    float3 e2 = quad[3].wcPos - quad[0].wcPos;
                    float3 tn_013 = normalize(cross(e1, e2));  // across from v1

                    // For Triangle 3, 1, 2
                    e1 = quad[2].wcPos - quad[1].wcPos;
                    e2 = quad[3].wcPos - quad[1].wcPos;
                    float3 tn_312 = normalize(cross(e1, e2)); // across from v2

                    // For Triangle 0, 3, 2
                    e1 = quad[0].wcPos - quad[2].wcPos; 
                    e2 = quad[3].wcPos - quad[2].wcPos;
                    float3 tn_032 = normalize(cross(e1, e2)); // across from v0

                    quad[3].normal = normalize(a0 * tn_312 + a1 * tn_032 + a2 * tn_013); 
                        // this vertex touches all three triangles, use barycentric coordinate to do weighted average

                    quad[0].normal = normalize(a1 * tn_032 + a2 * tn_013); 
                            // this vertex touches triangles 032 and 013
                    quad[1].normal = normalize(a0 * tn_312 + a2 * tn_013); 
                            // this vertex touches triangle 312 and 013
                    quad[2].normal = normalize(a0 * tn_312 + a1 * tn_032); 
                            // this vertex touches triangle 312 and 032

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
