Shader "552_Shaders/552_M2_Shader"
{
    // https://docs.unity3d.com/Manual/SL-Properties.html
    Properties
    {
          
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

            // located at: C:\Program Files\Unity\Hub\Editor\2021.3.10f1\Editor\Data\CGIncludes
            #include "UnityCG.cginc"

            struct DataFromVertex
            {
                float4 vertex : POSITION;
            };

            struct DataForFragmentShader
            {
                float4 vertex : SV_POSITION;
            };


            DataForFragmentShader VertexProgram(DataFromVertex input)
            {
                DataForFragmentShader output;
                float4 p = input.vertex;
                p = mul(unity_ObjectToWorld, p);  // objcet to world
                p = mul(UNITY_MATRIX_V, p);  // To view space
                p = mul(UNITY_MATRIX_P, p);  // Projection 
                output.vertex = p;
                return output;
            }

            float4 FragmentProgram(DataForFragmentShader input) : SV_Target
            {
                return float4(0, 1, 0, 1);
            }
            ENDCG
        }
    }
}
