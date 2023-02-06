Shader "Unlit/ShadowReceiver"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        // RenderQueue: smaller number gets render earlier
        // https://docs.unity3d.com/Manual/SL-SubShaderTags.html
        Tags { "RenderType"="Opaque" 
               "Queue" = "Geometry-1"    // make sure to render _BEFORE_ the rest (ProjectShadow shaders)
            }
        LOD 100

        Pass
        {
            // https://docs.unity3d.com/Manual/SL-Stencil.html
            // Always write a 2 into the Stencil
            Stencil {
                Ref 2
                Comp Always
                Pass Replace
            }
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "../CommonShaderCode/CommonDataStruct.cginc"
            #include "../CommonShaderCode/CommonVShader.cginc"
            #include "../CommonShaderCode/CommonFShader.cginc"
            ENDCG
        }  // Pass
    } // SubShader
}
