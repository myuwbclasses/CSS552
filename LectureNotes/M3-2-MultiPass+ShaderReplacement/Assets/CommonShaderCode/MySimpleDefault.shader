Shader "Unlit/MySimpleDefault"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color", Color) = (0.8,0.8,0.8,0)
    }
    
    SubShader
    {
        Tags { "RenderType"="Opaque" "ConstantColor" = "blue"}
        LOD 100
        // Cull Off

        Pass 
        {   
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "../CommonShaderCode/CommonDataStruct.cginc"
            #include "../CommonShaderCode/CommonVShader.cginc"
            #include "../CommonShaderCode/CommonFShader.cginc"
           
            ENDHLSL
        }
    }
}
