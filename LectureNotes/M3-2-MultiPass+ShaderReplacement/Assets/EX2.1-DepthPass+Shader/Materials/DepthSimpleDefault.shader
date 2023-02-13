Shader "Unlit/DepthSimpleDefault"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    
    SubShader
    {
        Tags { "RenderType"="Opaque" "DepthValue" = "InWC"}
        LOD 100
        // Cull Off

        Pass 
        {   
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "../../CommonShaderCode/CommonDataStruct.cginc"
            #include "../../CommonShaderCode/CommonVShader.cginc"
            #include "../../CommonShaderCode/CommonFShader.cginc"
           
            ENDCG
        }
    }
}
