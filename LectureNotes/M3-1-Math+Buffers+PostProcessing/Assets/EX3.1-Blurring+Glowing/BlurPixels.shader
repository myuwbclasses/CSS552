Shader "Unlit/BlurPixels"
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
            float _invWidth;    // in Normalized space
            float _invHeight;   // width and height of each pixel
            int FilterOn;
            static const int kFilterSize = 15;  // unfortunately, for loop only works with 
            static const float w = 1.0/(kFilterSize*kFilterSize);

            float4 filterOneRow(float x, float y) {  //Same y, where x-2, x-1, x, x+1, x+2
                float4 col = 0;
                float2 uv = float2(x-(((kFilterSize-1)/2)*_invWidth), y);
                for (int i=0; i<kFilterSize; i++) {
                    float4 n = tex2D(_MainTex, uv) * w; // KernelWeight[i];
                    col += n;
                    uv.x += _invWidth;
                }
                return col;
            }


            float4 frag (v2f fromV) : SV_Target
            {   
                float4 col = float4(0, 0, 0, 0); // tex2D(_MainTex, fromV.uv);

                float2 uv = float2(fromV.uv.x, fromV.uv.y-((((kFilterSize-1)/2))*_invHeight));
                for (int c = 0; c<kFilterSize; c++) {
                    col += filterOneRow(uv.x, uv.y);
                    uv.y += _invHeight;
                }
                return col;
            }
            ENDCG
        }
    }
}
