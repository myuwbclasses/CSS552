Shader "Unlit/MapLightIntensity"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _IntensityMap ("LightIntensity", 2D) = "white" {}
        _TransparenValue ("Transparent Value", Float) = 0.2
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

            float3 _LightU, _LightV;
            sampler2D _IntensityMap;
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
                }
                float3 L = normalize(_LightPos - i.worldPos);
                float NdotL = max(0.1, dot(i.normal, L)); // don't clam everything off 
                
                float lightIntensity = 1.0;
                if (_Control & kIntensity) {
                    float u = 0.5 * (dot(_LightU, L) + 1);
                    float v = 0.5 * (dot(_LightV, L) + 1);
                    lightIntensity = length(tex2D(_IntensityMap, float2(u, v)));
                }
                    
                if (_Control & kTransparency) {
                    if (lightIntensity > _TransparenValue)
                        discard;
                }

                return col * NdotL * lightIntensity;
            }
           
            ENDCG
        }
    }
}
