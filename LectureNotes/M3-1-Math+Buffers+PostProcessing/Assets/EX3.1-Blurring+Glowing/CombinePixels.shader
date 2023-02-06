Shader "Unlit/CombinePixels"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {} // this is the src of Blit
    }
    
    SubShader
    {
        Cull Off
        ZWrite Off
        ZTest Always

        Pass
        {   
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            sampler2D _AnotherImage;
            float _blendWeight; // How much of _AnotherImage to use

            float4 frag (v2f fromV) : SV_Target
            {   
                float4 c1 = tex2D(_MainTex, fromV.uv);
                float4 c2 = tex2D(_AnotherImage, fromV.uv);
                return c1 + _blendWeight * c2;;
            }
            ENDCG
        }
    }
}
