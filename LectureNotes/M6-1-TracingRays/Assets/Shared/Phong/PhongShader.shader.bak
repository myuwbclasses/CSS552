Shader "552_Shaders/PhongShader"
{
    // https://docs.unity3d.com/Manual/SL-Properties.html
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Ka ("Ambient", Color) = (0.1, 0.1, 0.1, 1)   // from MyMaterial.cginc
        _Kd ("Diffuse", Color) = (0.7, 0.8, 0.6, 1)
        _Ks ("Specular", Color) = (0.1, 0.1, 0.3, 1)
        _Specularity("n", float) = 1.0

            // Global control on LightLoader
        // _ShaderMode("Mode", int) = 0
            // Bits: On (yes) or Off (no)
            //  All off: returns black
            //   0: Texture   (1)
            //   1: Ambient   (2)
            //   2: Diffuse   (4)
            //   3: Specular  (8)
            //   4: Distance Attenuation (16)
            //   5: Angular Attenuation (32)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RayTracer" = "Regular" }
        LOD 100
        Cull off

        Pass
        {
            ColorMask RGB // Note: disabled A output 
                    // disabling transparency from Phong shading
                    // the alpha channel is used to pass RT Reflectivity
                    // to the RT Post Process
            HLSLPROGRAM
            #pragma vertex VertexProgram
            #pragma fragment FragmentProgram

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _CameraPosition;

            #include "MyInclude/PhongDataStruct.cginc"
            #include "MyInclude/MyMaterial.cginc"
            #include "MyInclude/MyLights.cginc"
            #include "MyInclude/MyPhong.cginc"

            #include "MyInclude/PhongVertAndFrag.cginc"
            
            ENDHLSL
        }
    }
}
