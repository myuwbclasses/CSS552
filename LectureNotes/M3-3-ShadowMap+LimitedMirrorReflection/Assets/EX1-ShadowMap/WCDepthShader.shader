
Shader "MyShaders/WCDepthShader"
{
	Properties
    {
	}

	SubShader {
		Tags {"RenderType"="Opaque" "DepthValue"="InWC"}
		Cull Off
		
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
            #pragma fragment frag
			#include "UnityCG.cginc"

			struct appdata { float4 vertex : POSITION; };
			struct v2f
			{
				float3 worldPos : TEXCOORD1;
				float3 viewPos :TEXCOORD2;
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v) {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex); 
                o.viewPos = mul(UNITY_MATRIX_MV, v.vertex);  // in Eye (Camera) space
                return o;
            }

			float4 frag(v2f i) : SV_Target
			{
				float len = length(i.viewPos);	
						// Eye space camera at origin and  distances are the same as WC
				float3 p = i.worldPos;
				
				return float4(p, len);  // outout range is 32-bit float
			}
			ENDCG
		}
	}
}