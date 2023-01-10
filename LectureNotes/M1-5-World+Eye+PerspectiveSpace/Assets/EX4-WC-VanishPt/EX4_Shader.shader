Shader "Unlit/EX4_Shader"
{
    Properties
    {
        _ShowFlag("Show: 0(None) 1(WC)", Integer) = 1
        _VPoint("VPoint: ", Vector) = (1, 0, 0, 1)
        _Space("VPoint Space: OC(0) WC(1)", Integer) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
    
        Pass
        {
            CGPROGRAM
                #include "../EX1-WC-ShowOC/P1-DrawInWC.cginc"
            ENDCG
        }
        Pass  // vanishes all vertices
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

                int _Space;
                float4 _VPoint;

                v2f vert (appdata v)
                {
                    v2f o;
                    float4 p;
                    p = v.vertex;  // this is position in object space
                    
                    if (_Space == 0) {
                        p += _SinTime.z * (_VPoint-p);  // sin of elapsed time 
                                                    // nice thing about sine function is it oscillates!
                        p = mul(unity_ObjectToWorld, p);  // objcet to world
                        
                    }
                    
                    if (_Space == 1) {
                        p = mul(unity_ObjectToWorld, p);  // objcet to world
                        p += _SinTime.z * (_VPoint-p);  // <-- WATCH OUT!!
                                                    // _VPoint is in OC and p is WC!!
                    }

                    p = mul(UNITY_MATRIX_V, p);  // To view space
                    p = mul(UNITY_MATRIX_P, p);  // to Projection 
                    o.vertex = p;
                    return o;
                }

                float4 frag (v2f i) : SV_Target
                {
                    return float4(0, 1, 0, 1);
                }
            ENDCG
        }

    }
}
