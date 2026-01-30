Shader "MyShaders/ConstantColor"
{
	SubShader {
		Tags { "ConstantColor" = "red" }
		Cull Off
		
		Pass
		{
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "../../CommonShaderCode/CommonDataStruct.cginc"
			#include "../../CommonShaderCode/CommonVShader.cginc"

			float4 frag(v2f i) : SV_Target
			{
				return float4(1.0, 0.0, 0.0, 1.0);
			}
			ENDHLSL
		}
	}

	SubShader {
		Tags { "ConstantColor" = "blue" }
		Cull Off
		
		Pass
		{
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "../../CommonShaderCode/CommonDataStruct.cginc"
			#include "../../CommonShaderCode/CommonVShader.cginc"

			float4 frag(v2f i) : SV_Target
			{
				return float4(0.0, 0.0, 1.0, 1.0);
			}
			ENDHLSL
		}
	}
}