Shader "Unlit/ShadowCaster"
{
    Properties
    {
        // Any varibble set by script, will not show here to avoid creating two UI setting this var

        _MainTex ("Texture", 2D) = "white" {}
        
        // Light position
        //      _LightPos("Light Position", Vector) = (0, 10, 0)
        
        // for shadow receiver
        //      _Normal("Receiver Normal", Vector) = (0, 1, 0)
        //      _D("Receiver D", float)  = 0
        // Receiver plane equation: dot(_Normal, p) - D = 0

        //      _ShadowColor("Color of Shadow", Color) = (0.2, 0.2, 0.2, 1.0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        Cull Off

        Pass
        {  

            // https://docs.unity3d.com/Manual/SL-Stencil.html
            // Write only if Stencil has content of 2
            // Assume the shadow receiver has rendered and set Stencil Psitions to 2
            Stencil {
                Ref 2
                Comp Equal
                // Pass Keep
            }

            // project Vertex to the plane
            // LightPos to p is a line
            //    l(t) = LightPos + t (v - LightPos)
            // Intersection with the receiver plane:
            //    _Normal dot l(t) - D = 0
            //          t = (D - (dot(n, LightPos)))  / (dot(n, (v - LightPos)))
            //    n is _Normal
            //    v is vertex position


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

            float3 _LightPos;  // in world space
            float3 _Normal; // normal of plane
            float _D; // D of plane
            float4 _ShadowColor; // color of the shadow
        
            v2f vert (appdata input)
            {
                v2f o;
                float4 p = input.vertex;

                p = mul(unity_ObjectToWorld, p);  // objcet to world

                // projection computation must e performed in world space
                float3 Vl = (p.xyz - _LightPos);
                float t = 0.99 * (_D - (dot(_Normal, _LightPos)))  / (dot(_Normal, Vl));
                        // fudge a little to not lie right on top of the receiver
                        // IF light is on the plane, Vl will be zero!! The shader will crash!

                p = float4(_LightPos + t * Vl, 1);

                p = mul(UNITY_MATRIX_V, p);  // To view space
                p = mul(UNITY_MATRIX_P, p);  // Projection 
                o.vertex = p;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                return _ShadowColor;  // color of shadow
            }
            ENDCG
        }
        Pass // normal pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "../CommonShaderCode/CommonDataStruct.cginc"
            #include "../CommonShaderCode/CommonVShader.cginc"
            #include "../CommonShaderCode/CommonFShader.cginc"
            ENDCG
        } // second pass
    } // SubShader
}
