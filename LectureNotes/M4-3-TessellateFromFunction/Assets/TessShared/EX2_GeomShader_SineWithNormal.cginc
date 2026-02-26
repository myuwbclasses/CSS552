#ifndef EX2_GEOM_SHADER
#define EX2_GEOM_SHADER

// This is the driver tessellation function. 
// In OC space, assume samplePt range between 0 to 1
// NOTE: the cool point here, 
//       From our OC vertex position, if we can normalize
//       any of the x/y/z to 0-1 range, then we can use the same function to 
//       compute height (and later the normal), without worrying about the actual scale of the geometry.
float ComputeYOffset(float samplePt, uint funcFlag) { 
    float theta = samplePt * UNITY_TWO_PI; 
    float delta = cos(theta);  // 

    if (ModeIsSet(funcFlag))
        delta = sin(theta);
    
    return delta;
}

// Compute height change in the + and - directions
// Again, samplePos is a numer between 0 and 1
float ApproxHeightDiff(float samplePos, float delta, uint funcFlag) {
    float left = ComputeYOffset(samplePos-delta, funcFlag);
    float right = ComputeYOffset(samplePos+delta, funcFlag);
    return right-left;
}   


// Receives output from the Domain Shader, invoked one-triangle at a time    
[maxvertexcount(3)]  // We will perform cleanup, not going to do more
void Geom(triangle Domain2Geom input[3], inout TriangleStream<Geom2Frag> triStream)
{
    Geom2Frag o[3];

    if (ModeIsSet(kXShowHeight|kZShowHeight)) {
        for (int i = 0; i < 3; i++) {
            o[i].uv = input[i].uv;
            o[i].color = input[i].color;

            // Position: we will re-sample the position based on the height map, and update the normal as well
            // recompute from OC space
            float3 oc = input[i].ocPos;
            float offsetFromX = 0;
            float deltaX = (0.01 * _NormalApproxDist) * _XPerPeriodOC;
            float heightDeltaX = 0;
            if (ModeIsSet(kXShowHeight)) {
                float samplePt = oc.x/_XPerPeriodOC;  // convert oc.x into units of peroid
                offsetFromX = ComputeYOffset(samplePt, kXAxisIsSine) * _XAmplitude;
                heightDeltaX = ApproxHeightDiff(samplePt, deltaX, kXAxisIsSine) * _XAmplitude;
            }
            oc.y += offsetFromX;

            o[i].wcPos = mul(unity_ObjectToWorld, float4(oc, 1.0)).xyz; // Get the world space position from ocPos 
            o[i].pcPos = UnityObjectToClipPos(float4(oc, 1.0)); // Recompute the clip space position

            // Normal
            // Since no y-change along Z
            // V1 = (2dx, offsetFromX, 0) and V2 = (0, 0, 2dz)
            // N = cross(V2, V1) = (-offsetFromX*2dz, 4dx*dz, 0)
            // Assuming dx = dz ... 
            float3 n = normalize(float3(-heightDeltaX*deltaX*2, 4*deltaX*deltaX, 0));

            if (ModeIsSet(kDebugShowXHeightChange))
                n = normalize(float3(-heightDeltaX, -heightDeltaX, -heightDeltaX));
            
            o[i].wcNormal = normalize(mul(n, (float3x3)unity_WorldToObject)); // Recompute the normal with slope approximation
        }
    } else {
        for (int i = 0; i < 3; i++) {
            o[i].pcPos = input[i].pcPos;
            o[i].wcPos = mul(unity_ObjectToWorld, float4(input[i].ocPos, 1.0)).xyz; // Get the world space position from ocPos
            o[i].wcNormal = normalize(mul(input[i].ocNormal, (float3x3)unity_WorldToObject)); // Recompute the normal with slope approximation
            o[i].uv = input[i].uv;
            o[i].color = input[i].color;
        }

    }

    // simply by-pass
    triStream.Append(o[0]);
    triStream.Append(o[1]);
    triStream.Append(o[2]);
    triStream.RestartStrip();
}
#endif // EX2_GEOM_SHADER