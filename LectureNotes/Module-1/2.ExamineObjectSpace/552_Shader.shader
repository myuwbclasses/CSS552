Shader "552_Shaders/552_MP1_Shader"
{
    // https://docs.unity3d.com/Manual/SL-Properties.html
    Properties
    {
        _Color("Color", Color) = (0.8, 0.8, 1, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        Cull off

        Pass
        {
            CGPROGRAM
            #pragma vertex VertexProgram
            #pragma fragment FragmentProgram

            #include "UnityCG.cginc"

            struct DataFromVertex
            {
                float4 vertex : POSITION;
            };

            struct DataForFragmentShader
            {
                float4 vertex : SV_POSITION;
            };

            struct OutputFromFragmentShader {
                float4 color : SV_Target;
            };

            float4 _Color;

            // Variables provided by Unity:
            //        https://docs.unity3d.com/Manual/SL-UnityShaderVariables.html
            //
            DataForFragmentShader VertexProgram(DataFromVertex input)
            {
                DataForFragmentShader output;
                float4 p = input.vertex;

                p = mul(unity_ObjectToWorld, p);  // objcet to world
                p = mul(UNITY_MATRIX_V, p);  // To view space
                output.vertex = mul(UNITY_MATRIX_P, p);  // Projection 
                
                return output;
            }

            OutputFromFragmentShader FragmentProgram(DataForFragmentShader input)
            {
                OutputFromFragmentShader output;
                output.color = _Color;
                return output;
            }
            ENDCG
        }
    }
}
