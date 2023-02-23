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
            sampler2D _MirrorImage;
            uint _ShowFlag;

            const static uint kShowNoFlip = 0x0;
            const static uint kShowFlipU = 0x01;
            const static uint kShowFlipV = 0x02;
            

            float4 frag (v2f fromV) : SV_Target
            {   
                float2 uv = fromV.uv;

                float4 mainColor = tex2D(_MainTex, fromV.uv);

                if (_ShowFlag & kShowFlipU)
                    uv.x = 1 - uv.x;
                
                if (_ShowFlag & kShowFlipV)
                    uv.y = 1 - uv.y;

                float4 mirrorColor = tex2D(_MirrorImage, uv);
                float blend = mainColor.a; // this says how much of mainColor to show

                return mainColor * blend + mirrorColor * (1-blend);
                        // Note: Use Alpha as Mask (blend)
                        // in the MainCam
                        //      the Mirror region has mask = 0 (Mirror.Shader)
                        //      Except, objects over mirror region will have mask set to 1
                        // This blending favors MainCam over MirrorCam results
                        // Or, when overlaps, show MainCam object
            }
            ENDCG
        }
    }
}
