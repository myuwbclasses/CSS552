#ifndef RT_WCDepthDataStructAndVert
#define RT_WCDepthDataStructAndVert

#include "UnityCG.cginc"

struct appdata { 
	float4 vertex : POSITION; 
	float3 normal : NORMAL;
};

struct v2f
{
	float3 wcPos : TEXCOORD1;
	float3 wcNormal : NORMAL;
	float4 vertex : SV_POSITION;
};

// We need multiple render targets here to output position and normal.
// I used ChatGPT to figure how to do this via Unity:
// ChatGPT phrase:
//      in unity with custom shader that output to multiple targets, how do I set up the render texture on the scripting side
//
struct FragOutput {
	fixed4 c0 : SV_Target0; // zeroth render texture
	fixed4 c1 : SV_Target1; // first render texture
};

v2f vert (appdata v) {
	v2f o;
	o.vertex = UnityObjectToClipPos(v.vertex);
	o.wcPos = mul(unity_ObjectToWorld, v.vertex); 
	o.wcNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject)); 
	return o;
}
			
#endif // RT_WCDepthDataStructAndVert