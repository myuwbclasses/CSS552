Shader "552/BlendShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        // RenderTag: https://docs.unity3d.com/Manual/SL-SubShaderTags.html  
        Tags { "RenderType"="Transparent" "Queue"="Transparent+2" } 
        // The default for Transparent is 3000
                // Unsure what this Tag is for, ignore for now

               
        LOD 100

        Pass
        {
            // https://docs.unity3d.com/Manual/SL-Blend.html
            Blend SrcAlpha OneMinusSrcAlpha
                // Examples of Different ways of blending
                // Blend SrcAlpha OneMinusSrcAlpha // Traditional transparency
                // Blend One OneMinusSrcAlpha // Premultiplied transparency
                // Blend One One // Additive
                // Blend OneMinusDstColor One // Soft additive
                // Blend DstColor Zero // Multiplicative
                // Blend DstColor SrcColor // 2x multiplicative

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                // sample the texture
                float4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
