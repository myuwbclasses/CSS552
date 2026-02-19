Shader"Custom/EX_HeightMapped"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
                // Defined in this file
        _LightInfo ("Light Info", Vector) = (0, 1, 0, 1) 
                // Defined in TessFlag.cginc
        
                // Defined in SimplePatchConstantFunction.cginc
        _PatchEdge ("Patch Edge", Range(1, 64)) = 4
                // 0 will hide the geometry altogether
        _PatchInside ("Patch Inside", Range(0, 20)) = 1
                // These two defined in this file
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
            
            // These three are new!
            #include "../TessShared/EX1_TessFunction_Simple.cginc"
            #include "../TessShared/EX1_Hull_Simple.cginc"
            
            // New Domain Shader to displace the vertices along normal direction based on the height map texture
            #include "../TessShared/EX2_Domain_Height.cginc"
                    // This defines the HeightDomain shader, which is used to 
                    // displace the vertices along normal direction based on the height map texture
                
            // SimpleFrag: 
            //    Works with ControlFlags.cginc
            //    Able to display UV, Color, Normal, NdotL, etc. as color
            #include "../TessShared/EX1_Frag_Simple.cginc"            
            ENDHLSL
        }
    }
}
