Shader"Custom/EX2-SineWithNormal"
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
            #pragma vertex Vert
            #pragma hull Hull
            #pragma domain Domain
            #pragma geometry Geom
            #pragma fragment Frag

            #pragma target 5.0

            #include "UnityCG.cginc"
            #include "./../TessShared/TessStruct.cginc"
            #include "./../TessShared/TessControlFlags.cginc"
            #include "./../TessShared/SupportFunc.cginc"
            
            sampler2D _MainTex;

            // Our own cleaner Vert Shader
            #include "./../TessShared/VertShader.cginc"
            
            // Tessellation shaders
            #include "./../TessShared/HullShader.cginc"
    
            
            float _XAmplitude; // 
            float _XPerPeriodOC;

            float _NormalApproxDist;

// Only going to change this function
            #include "./../TessShared/EX1_TessFunction_ScreenSpace.cginc"
            
            #include "./../TessShared/DomainShader.cginc"

// And this shader!
            #include "./../TessShared/EX2_GeomShader_SineWithNormal.cginc"


            #include "./../TessShared/FragShader.cginc"            
            ENDHLSL
        }
    }
}
