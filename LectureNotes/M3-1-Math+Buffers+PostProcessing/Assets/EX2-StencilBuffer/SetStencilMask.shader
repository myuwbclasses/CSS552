Shader "Unlit/SetStencilMask"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _StencilMask ("Stencil Make", Integer) = 1
    }
    
    SubShader
    {
        // RenderQueue: smaller number gets render earlier
        // https://docs.unity3d.com/Manual/SL-SubShaderTags.html
        Tags { "RenderType"="Opaque" 
               "Queue" = "Geometry-1"   // make sure to render before typical opaque geometries
            }
        LOD 100
        Cull Off
        ZWrite Off
        // ZWrite On  // writes in (with with ZTest Greater to show what is behind)

        Pass  // Creates the Mask
        {
            // https://docs.unity3d.com/Manual/SL-Stencil.html
            // Always write a 2 into the Stencil
            Stencil {
                Ref [_StencilMask]
                Comp Always
                Pass Replace
            }
            ColorMask R
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "../CommonShaderCode/CommonDataStruct.cginc"
            #include "../CommonShaderCode/CommonVShader.cginc"
            #include "../CommonShaderCode/CommonFShader.cginc"

            
            ENDCG
        }
    }
}
