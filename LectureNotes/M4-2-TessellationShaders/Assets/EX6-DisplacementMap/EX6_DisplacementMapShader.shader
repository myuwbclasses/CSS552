Shader"Custom/EX_DisplacementMapShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Pass
        {
            Cull Off
            
            HLSLPROGRAM
            // Check out the many shader programs!
            #pragma vertex EX6Vert
            #pragma hull EX6Hull
            #pragma domain EX6Domain
            #pragma geometry EX6Geom
            #pragma fragment SimpleFrag

            #pragma target 5.0

            #include "UnityCG.cginc"
            #include "EX6_Shaders/EX6_TessStruct.cginc"   // EX6 Specific
            #include "../TessShared/TessControlFlags.cginc"
            #include "../TessShared/SupportFunc.cginc"
            
            sampler2D _MainTex;

            // To skip Hull Shader
            // #define Vert2Hull OutputFromHull

            // Our own cleaner Vert Shader
            #include "EX6_Shaders/EX6VertShader.cginc"
            
            // Tessellation shaders
            #include "EX6_Shaders/EX6HullShader.cginc"
            
            // Tp skip HullShader
            // #define OutputFromHull Domain2Geom
            // Screen space tessellation
            #include "../TessShared/EX3_TessFunction_ScreenSpace.cginc"
            
            #include "EX6_Shaders/EX6DomainShader.cginc"

            #include "EX6_Shaders/EX6GeomShader.cginc"
                // re-sample height map, and re-approx normal
                // if we are performing these here, then, can remove from previous stages

            // SimpleFrag: 
            //    Works with ControlFlags.cginc
            //    Able to display UV, Color, Normal, NdotL, etc. as color
            #define Domain2Frag Geom2Frag
                    // to cheat SimpleFrag
            #include "../TessShared/EX1_Frag_Simple.cginc"            
            ENDHLSL
        }
    }
}
