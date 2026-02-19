Shader"Custom/EX_SimpleTess"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
                // Defined in this file
        _LightInfo ("Light Info", Vector) = (0, 1, 0, 1) 
                // Defined in TessFlag.cginc
        _HullOffsetAmount ("Hull Offset Amount", Range(0, 1)) = 0 // How much to offset V0 hull along normal direction. 1 means offset by the length of normal vector.
                // Defined in SimpleHull.cginc

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
            #pragma domain SimpleDomain
            // #pragma geometry SimpleGeom  // This will be next!
            #pragma fragment SimpleFrag

            #pragma target 5.0

            #include "UnityCG.cginc"
            #include "../TessShared/TessStruct.cginc"
            #include "../TessShared/TessControlFlags.cginc"
            #include "../TessShared/SupportFunc.cginc"
            
            sampler2D _MainTex;

            // This is SimpleVert
            #include "../TessShared/EX1_Vert_Simple.cginc"
            
            // These three are new: Tessellation support
            #include "../TessShared/EX1_TessFunction_Simple.cginc"
            #include "../TessShared/EX1_Hull_Simple.cginc"
            #include "../TessShared/EX1_Domain_Simple.cginc"
            
            // SimpleFrag: 
            //    Works with ControlFlags.cginc
            //    Able to display UV, Color, Normal, NdotL, etc. as color
            #include "../TessShared/EX1_Frag_Simple.cginc"            
            ENDHLSL
        }
    }
}
