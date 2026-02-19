Shader"Custom/EX_ScreenSpaceTess"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _LightInfo ("Light Info", Vector) = (0, 1, 0, 1)
        _EdgeLength ("Edge Length", Range(0.5, 100)) = 30     // Desired edge length of triangle
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Pass
        {
            Cull Off
            
            HLSLPROGRAM
            // Check out the many shader programs!
            #pragma vertex SimpleVert
            #pragma hull SimpleHull
            #pragma domain SimpleDomain
            // #pragma geometry geom  // This will be next!
            #pragma fragment SimpleFrag

            #pragma target 5.0

            #include "UnityCG.cginc"
            #include "../TessShared/TessStruct.cginc"
            #include "../TessShared/TessControlFlags.cginc"
            #include "../TessShared/SupportFunc.cginc"
            
            sampler2D _MainTex;

            // This is SimpleVert
            #include "../TessShared/EX1_Vert_Simple.cginc"
            
            // Tsellation shaders
            #include "../TessShared/EX1_Hull_Simple.cginc"

            // Screen space tess function
            #include "../TessShared/EX3_TessFunction_ScreenSpace.cginc"

            #include "../TessShared/EX1_Domain_Simple.cginc"
                // For now, perform simple interpolation

            // SimpleFrag: 
            //    Works with ControlFlags.cginc
            //    Able to display UV, Color, Normal, NdotL, etc. as color
            #include "../TessShared/EX1_Frag_Simple.cginc"            
            ENDHLSL
        }
    }
}
