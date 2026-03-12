Shader "MyShaders/RT_PrePassShader"
{
	Properties
    {
	}

	SubShader {
		Tags {"RenderType"="Opaque" "RayTracer"="Reflective"}
		Cull Off
		
		Pass
		{
			HLSLPROGRAM
			#pragma vertex vert
            #pragma fragment frag
		
			#include "./RT_PrePassDataStructAndVert.cginc"
			
			FragOutput frag(v2f i)
			{
				FragOutput output;
				output.c0 = float4(i.wcPos, 1.0);  
						// alpha = 1.0 means reflective
				output.c1 = float4(i.wcNormal, 1.0);
				return output;
			}
			ENDHLSL
		}
	}

	SubShader {
		Tags {"RenderType"="Opaque" "RayTracer"="Regular"}
		Cull Off
		
		Pass
		{
			HLSLPROGRAM
			#pragma vertex vert
            #pragma fragment frag
		
			#include "./RT_PrePassDataStructAndVert.cginc"

			FragOutput frag(v2f i)
			{
				FragOutput output;
				output.c0 = float4(i.wcPos, 0.0);  
						// alpha = 0.0 means NOT reflective
				output.c1 = float4(i.wcNormal, 1.0);
				return output;
			}
			ENDHLSL
		}
	}
}