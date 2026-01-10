Shader "552_Shaders/552_MP3_Shader"
{
    // https://docs.unity3d.com/Manual/SL-Properties.html
    Properties
    {
       // world space 
        _UserControl("User Control", Integer) = 0  // 1 is user control 

        // Object Space
        _OCWeight("OC Weight", float) = 1
        _OCVPoint("OC Vanishing Pt", Vector) = (0, 0, 0)

        // World space control
        _WCWeight("WC Weight", float) = 1  // 
        _WCRate("WC Rate", float) = 1 // 
        _WCVPoint("Vanishing Point", Vector) = (0, 0, 0)  // WC Vanishing point

        // Eye Coordinate control
         _ECNear("Near", float) = 0.3  // Near point distance of the camera
                  // In Eye Coordinate: Center of Window is (0, 0, -Near)
        _ECWeight("EC Weight", float) = 1

        // Projected Coordinate control
        _PCWeight("PC Weight", float) = 1
        _PCVPoint("PC Vanishing Pt", Vector) = (0, 0, 0)
        

        _Color("Color", Color) = (0.8, 0.8, 1, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        Cull off
        Pass  // Vanishing in object coordinate space
        {
            HLSLPROGRAM
                // OC pass code

                // Note: if you want to put your implementation in a separate file and use
                //           #include "filename"
                //       you MUST define the vertex and fragment shader functions with
                //
                //          #pragma vertex VertexProgram_name
                //          #pragma fragment FragmentProgram_name
                //          #include "filename"
                // 
                // Without the #prama definitions, the pre-processor will freak-out and not compile!
            ENDHLSL
        }

        Pass  // Vanishing towards the world point
        {
            HLSLPROGRAM
                // WC Pass code
            ENDHLSL
        }

        Pass // Vanishing in eye space
        {
            HLSLPROGRAM
                // EC Pass
            ENDHLSL
        }
        Pass  // Vanishing towards the center of window in projected coordinate
        {
            HLSLPROGRAM
                // PC Pass
            ENDHLSL
        }

        Pass // Show original in white
        {
            HLSLPROGRAM
                #pragma vertex VertexProgram
                #pragma fragment FragmentProgram

                #include "UnityCG.cginc"
                #include "Structs.cginc"   

                int _UserControl;
                float4 _Color;    

                // Variables provided by Unity:
                //        https://docs.unity3d.com/Manual/SL-UnityShaderVariables.html
                //
                DataForFragmentShader VertexProgram(DataFromVertex input)
                {
                    DataForFragmentShader output;
                    float4 p = input.vertex;

                    p = mul(unity_ObjectToWorld, p);  // objcet to world
                    p = mul(UNITY_MATRIX_V, p);  // To eye space
                    p = mul(UNITY_MATRIX_P, p);  // Projection 
                    
                    output.vertex = p;

                    return output;
                }

                OutputFromFragmentShader FragmentProgram(DataForFragmentShader input)
                {
                    OutputFromFragmentShader output;
                    if (!FLAG_IS_ON(SHOW_ORIGINAL))
                        discard;
                    output.color = _Color;
                    return output;
                }
            ENDHLSL

        } // Pass
    } // SubShader
}
