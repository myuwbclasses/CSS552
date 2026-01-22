Shader "552_Shaders/VizSpecularTerms"
{
    Properties
    {
        _Smoothness("Smoothness", Range(0.05, 1.0)) = 0.5
        _Shinniness("n", Range(1.0, 100)) = 1.0
        _RefIndex("Ref Index", Range(1.0, 4.0)) = 1.0
        _SpecBoost("Boost", Range(1.0, 5.0)) = 2.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        Cull off

        Pass
        {
            HLSLPROGRAM
            #pragma vertex VertexProgram
            #pragma fragment FragmentProgram

            // located at: C:\Program Files\Unity\Hub\Editor\2021.3.10f1\Editor\Data\CGIncludes
            #include "UnityCG.cginc"
            #include "SpecularTerms.cginc"

            struct DataFromVertex
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct DataForFragmentShader
            {
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
                float3 worldPos : TEXCOORD1;
            };

            float3 _CameraPos;  // SceneControlBase::Update() uses these IDs
            float3 _MyLightPos;
            float _SpecBoost;

            // Variables provided by Unity:
            //        https://docs.unity3d.com/Manual/SL-UnityShaderVariables.html
            //
            DataForFragmentShader VertexProgram(DataFromVertex input)
            {
                DataForFragmentShader output;
                
                float4 p = mul(unity_ObjectToWorld, input.vertex);  // objcet to world
                output.worldPos = p.xyz;  // p.w is 1.0 at this poit
                p = mul(UNITY_MATRIX_V, p);  // To view space
                output.vertex = mul(UNITY_MATRIX_P, p);  // Projection 
                
                output.normal = normalize(mul(input.normal, (float3x3)unity_WorldToObject));  // if scaled and ignore translation
                        // Transpose of Inversed(unity_ObjectToWorld)

                return output;
            }

            float4 FragmentProgram(DataForFragmentShader input) : SV_Target
            {
                float3 N = input.normal;
                float3 V = normalize(_CameraPos - input.worldPos);
                float3 L = normalize(_MyLightPos - input.worldPos);
                float3 H = (L + V) * 0.5;

                float spec = ShowSpecular(V, H, N, L);
                spec = pow(spec, 1.0/_SpecBoost);
                return float4(spec, spec, spec, 1.0);
            }
            ENDHLSL
        }
    }
}
