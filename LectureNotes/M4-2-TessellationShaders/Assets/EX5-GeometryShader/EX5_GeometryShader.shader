Shader"Custom/EX_GeometryShader"
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
            #pragma domain HeightDomain
            #pragma geometry HeightGeom
            #pragma fragment SimpleFrag

            #pragma target 5.0

            #include "UnityCG.cginc"
            #include "../TessShared/TessStruct.cginc"
            #include "../TessShared/TessControlFlags.cginc"
            #include "../TessShared/SupportFunc.cginc"
            
            sampler2D _MainTex;

            // This is SimpleVert
            #include "../TessShared/EX1_Vert_Simple.cginc"
            
            // Tessellation shaders
            #include "../TessShared/EX1_Hull_Simple.cginc"
            
            // Screen space tessellation
            #include "../TessShared/EX3_TessFunction_ScreenSpace.cginc"
                // This defines the ComputeTessFactor function, which computes tessellation factors based on edge length in screen space
            
            // Now, height map
            #include "../TessShared/EX2_Domain_Height.cginc"
                // This defines the HeightDomain shader, which is used to 
                // displace the vertices along normal direction based on the height map texture

            #include "../TessShared/EX5_Geom_Height.cginc"
                // re-sample height map, and re-approx normal
                // if we are performing these here, then, can remove from previous stages

            // SimpleFrag: 
            //    Works with ControlFlags.cginc
            //    Able to display UV, Color, Normal, NdotL, etc. as color
            #include "../TessShared/EX1_Frag_Simple.cginc"            
            ENDHLSL
        }
    }
}
