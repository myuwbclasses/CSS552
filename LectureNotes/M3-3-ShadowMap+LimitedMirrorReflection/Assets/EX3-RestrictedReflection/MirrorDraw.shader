Shader "Unlit/MirrorDraw"
{
    Properties
    {
        
    }
    SubShader  // Draw Objects in Mirror (referencing to Stencil)
    {
        Tags { "RenderType"="Opaque" "MyReflection" = "Object"}
        LOD 100
        Cull Off

        Pass
        {
            
            Stencil {
                Ref 1
                Comp Equal
            } 

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "../CommonShaderCode/CommonDataStruct.cginc"
            #include "../CommonShaderCode/CommonVShader.cginc"
            #include "../CommonShaderCode/CommonFShader.cginc"
            
            ENDCG
        }
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" 
               "MyReflection" = "Mirror"   
               "Queue" = "Geometry-1"}
               // Draws the  "Mirror" object
               // Draw _BEFORE_ "Geometry" (switch on Stencil)
        LOD 100
        Cull Off

        Pass // Drawing the mirror (switch on stencil)
        {
            Stencil {
                Ref 1
                Comp Always
                Pass Replace
            }
            ZWrite Off  // do not leave foot print in Z-buffer
                        // Remember, MirrorCam is "behind the mirror"
                        //           If Z-buffer write is on, will occlude everything!


            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            float4 _MirrorColor;

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
            };


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return _MirrorColor;
            }
            ENDCG
        }
    }
}
