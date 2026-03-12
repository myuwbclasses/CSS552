Shader "Unlit/RT_PostProcess-EX2"
{
    Properties
    {
    }
    
    SubShader
    {
        Cull Off
        ZWrite Off
        ZTest Always

        Pass
        {   
            ColorMask RGB
                // .a us highjacked for reflectivity
                //    don't use it
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
           
           struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            // The Triangle
            float4 _TheTriangle[3];
            float4 _TriNormal;  // Triangle Normal (normalized)
            float _TriD; // n . p - D = 0
            float _TriA2Inv;   // Inverse of 2x Triangle Area

            // The Sphere
            float4 _TheCenter;
            float  _TheRadius;    

            sampler2D _MainTex;
            sampler2D _RT_Position;
            sampler2D _RT_Normal;

            float _RT_ShadowStrength;
            float4 _RT_BackgroundColor;

            float3 _CameraPosition;

            #include "../Shared/RT_MacrosAndConst.cginc"
            #include "../Shared/Phong/MyInclude/PhongDataStruct.cginc"
            #include "../Shared/Phong/MyInclude/MyMaterial.cginc"
            #include "../Shared/Phong/MyInclude/MyLights.cginc"

            #include "../Shared/RayFunctions.cginc"
            
            #include "../Shared/RT_Intersect.cginc"

            #include "../Shared/Phong/MyInclude/MyPhong.cginc"
            
            #include "../Shared/RT_Shade.cginc"
            #include "../Shared/RT_Sphere.cginc"
            #include "../Shared/RT_Triangle.cginc"

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            // https://learn.microsoft.com/en-us/windows/win32/direct3d9/fog-formulas
            float4 frag (v2f fromV) : SV_Target
            {   
                float4 pixelColor = tex2D(_MainTex, fromV.uv);
                float4 p = tex2D(_RT_Position, fromV.uv);
                
                if (!IsReflective(p)) 
                    return pixelColor;
                
                DEBUG_SHOW(kShowRTObjectInRed, float4(1, 0, 0, 1))
                                    
                float3 n = normalize(tex2D(_RT_Normal, fromV.uv).xyz);
                DEBUG_SHOW(kShowRTNormal, (0.5*float4(n,1.0)+0.5))

                CONDITION_DEBUG(InSphere(p), kShowSphereInBlue, float4(0,0,1,1))
                    // Verify Circle info is properly passed, and InSphere logic is correct

                CONDITION_DEBUG(InTriangle(p), kShowTriangleInGreen, float4(0, 1, 0, 1))
                    // Verify triangle info is passed correctly, and, BC is working
                
                return pixelColor;
            }
            ENDHLSL
        }
    }
}