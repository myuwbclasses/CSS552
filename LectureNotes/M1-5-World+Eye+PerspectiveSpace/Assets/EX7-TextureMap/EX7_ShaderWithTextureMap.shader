Shader "Unlit/EX7_ShaderWithTextureMap"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _SecTex ("Second Texture", 2D) = "black" {}
        _Blend("Blend Factor", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float2 uv1 : TEXCOORD1; // Note: TEXCOORD1
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float2 uv1 : TEXCOORD1;  // Note: TEXCOORD1
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _SecTex;
            float4 _SecTex_ST;  // for second texture placement

            float _Blend;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                    // Defined in: C:\Program Files\Unity\Hub\Editor\2021.3.10f1\Editor\Data\CGIncludes
                    // o.uv = v.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv1 = TRANSFORM_TEX(v.uv1, _SecTex);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                // sample the texture
                float4 c1 = tex2D(_MainTex, i.uv);
                float4 c2 = tex2D(_SecTex, i.uv1);
                
                return _Blend * c1 + (1-_Blend) * c2;
            }
            ENDCG
        }
    }
}
