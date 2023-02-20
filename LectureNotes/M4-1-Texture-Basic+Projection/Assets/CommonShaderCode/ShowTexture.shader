Shader "Unlit/ShowTexture"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    
    SubShader
    {
        Tags { "RenderType"="Opaque"}
        LOD 100
        Cull Off

        Pass 
        {   
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag

            #include "./CommonDataStruct.cginc"
            #include "./CommonVShader.cginc"

            float4 frag(v2f i) : SV_Target {
                float4 c = tex2D(_MainTex, i.uv);
                return c;
            }
           
            ENDCG
        }
    }
}
