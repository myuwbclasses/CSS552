Shader "Unlit/MappedFragment"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _IntensityMap ("Intensity", 2D) = "white" {}
        _TransparencyMap ("Transparency", 2D) = "white" {}
        _TransparenValue ("Transparent value", Float) = 0.2
        _Control ("0-Off 1-Intensity 2-Transparency", Integer) = 0
    }
    
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        Cull Off

        Pass 
        {   
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "../CommonShaderCode/CommonDataStruct.cginc"
            #include "../CommonShaderCode/CommonVShader.cginc"

            sampler2D _IntensityMap;
            sampler2D _TransparencyMap;
            float _TransparenValue;
            uint _Control;  
            static const int kNoMap = 0x0;
            static const int kIntensity = 0x01;
            static const int kTransparency = 0x02;
            
            float4 frag (v2f i) : SV_Target
            {
                // sample the texture
                float4 col = float4(0.9, 0.7, 0.7, 1.0);
                if ((i.uv.x != 0) && (i.uv.y != 0)) {
                    col = tex2D(_MainTex, i.uv);

                    if (_Control & kIntensity) {
                        // col += tex2D(_IntensityMap, i.uv);
                        col *= length(tex2D(_IntensityMap, i.uv));
                        // col += 1-length(tex2D(_IntensityMap, i.uv));
                    }
                    
                    if (_Control & kTransparency) {
                        float t = length(tex2D(_TransparencyMap, i.uv));
                        if (t < _TransparenValue)
                            discard;
                    }
                }
                float3 L = normalize(_LightPos - i.worldPos);
                float NdotL = max(0.1, dot(i.normal, L)); // don't clam everything off 
                return col * NdotL;
            }
           
            ENDCG
        }
    }
}
