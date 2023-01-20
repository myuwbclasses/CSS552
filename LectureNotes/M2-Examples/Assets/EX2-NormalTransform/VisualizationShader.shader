Shader "552/Visualization-Shader"
{
    Properties
    {
        _Flag("Show: 0:WorldPt 1:Normal", Integer) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        Cull off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;   // in OC
            };

            struct v2f {
                float4 vertex : SV_POSITION;
                float3 worldPt : TEXCOORD1;  // in WC
                float3 normal : NORMAL;      // in WC
            };

            int _Flag;
            
            // Remember all world position is in the range of 0 to 10 (within the Cube)
            // To show as color for WorldPt, must divide by 10 or * 0.1
            #define WORLD_SIZE  0.1
            
            v2f vert (appdata v) {
                v2f o;
                float4 p = v.vertex;
                p = mul(unity_ObjectToWorld, p);
                o.worldPt = p.xyz;  // world point, passing down to fragment shader
                p = mul(UNITY_MATRIX_V, p);
                p = mul(UNITY_MATRIX_P, p);
                o.vertex = p;  // in NDC for scan conversion

                // now work on the normal
                o.normal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
                        // normalize: to take care of if there is scaling in the world 
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float4 col = float4(0, 0, 0, 1);

                if (_Flag == 0) { // show position as color
                                  // remember position is between 0 < xyz < WORLD_SIZE
                    col.xyz = i.worldPt * WORLD_SIZE;
                } else {
                    // normal is -1 < xyz < 1
                    // to convert to 0 < xyz < 1  (for showing as color)
                    // color = 0.5 * (n+1)
                    col.xyz = (i.normal + float3(1, 1, 1)) * 0.5;
                        // Note: (0, 1, 0): default of a plane will become
                        //       (1, 2, 1) and then
                        //       (0.5, 1, 0.5)  <-- what we observe
                }
                
                return col;
            }
            ENDCG
        }
    }
}
