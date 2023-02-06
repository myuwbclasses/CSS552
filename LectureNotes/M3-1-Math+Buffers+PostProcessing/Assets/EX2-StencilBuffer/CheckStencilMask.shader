Shader "Unlit/CheckStencilMask"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _StencilMask ("Stencil Make", Integer) = 1
    }
    
    SubShader
    {
        Tags { "RenderType"="Opaque" }  // no need to mess with the Queue
        LOD 100
        Cull Off
        // ZTest Greater // to work with SetStencilMask: ZWrite on

        Pass  // Creates the Mask
        {
            // https://docs.unity3d.com/Manual/SL-Stencil.html
            // Always write a 2 into the Stencil
            Stencil {
                Ref [_StencilMask]
                Comp Equal           // only when equal can we draw
            }
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "../CommonShaderCode/CommonDataStruct.cginc"
            #include "../CommonShaderCode/CommonVShader.cginc"
            #include "../CommonShaderCode/CommonFShader.cginc"
            //    Using the common fragment shader results in black!
            //    Why? Geometry has no UV defined!?
            
            ENDCG
        }
    }
}
