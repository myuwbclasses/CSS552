#ifndef HEIGHT_GEOM
#define HEIGHT_GEOM
       
// Receives output from the Domain Shader, invoked one-triangle at a time    
[maxvertexcount(3)]  // We will perform cleanup, not going to do more
void HeightGeom(triangle Domain2Frag input[3], inout TriangleStream<Domain2Frag> triStream)
{
    Domain2Frag o[3];

    if (ModeIsSet(kGeomComputeHeight)) {
        for (int i = 0; i < 3; i++) {
            o[i].uv = input[i].uv;
            o[i].uv1 = input[i].uv1;
            o[i].color = input[i].color;
            o[i].ocPos = input[i].ocPos; // Pass the original OC position down (to Geometry and Fragment)

            // Position: we will re-sample the position based on the height map, and update the normal as well
            // recompute from OC space
            float3 oc = input[i].ocPos;
            oc.y += ComputeHeightFormMap(o[i].uv); // Sample the height map
            o[i].wcPos = mul(unity_ObjectToWorld, float4(oc, 1.0)).xyz; // Get the world space position from ocPos 
            o[i].pcPos = UnityObjectToClipPos(float4(oc, 1.0)); // Recompute the clip space position

            // Normal
            float3 n = ApproxNormalWithMap(o[i].uv);
            o[i].wcNormal = normalize(mul(n, (float3x3)unity_WorldToObject)); // Recompute the normal with slope approximation
        }
    } else {
        for (int i = 0; i < 3; i++) {
            o[i].pcPos = input[i].pcPos;
            o[i].wcPos = input[i].wcPos;
            o[i].ocPos = input[i].ocPos;
            o[i].wcNormal = input[i].wcNormal;
            o[i].uv = input[i].uv;
            o[i].uv1 = input[i].uv1;
            o[i].color = input[i].color;
        }

    }

    // simply by-pass
    triStream.Append(o[0]);
    triStream.Append(o[1]);
    triStream.Append(o[2]);
    triStream.RestartStrip();
}
#endif // HEIGHT_GEOM