#ifndef EX4_GEOM_SHADER
#define EX4_GEOM_SHADER

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
                offsetFromX = ComputeYOffset(samplePt, kXAxisIsSine) * _XAmplitude * _XZBlend;
                heightDeltaX = ApproxHeightDiff(samplePt, deltaX, kXAxisIsSine) * _XAmplitude * _XZBlend;
            }

            float offsetFromZ = 0;
            float deltaZ = (0.01 * _NormalApproxDist) * _ZPerPeriodOC;
            float heightDeltaZ = 0;
            if (ModeIsSet(kZShowHeight)) {
                float samplePt = oc.z/_ZPerPeriodOC;  // convert oc.z into units of peroid
                offsetFromZ = ComputeYOffset(samplePt, kZAxisIsSine) * _ZAmplitude * (1-_XZBlend);
                heightDeltaZ = ApproxHeightDiff(samplePt, deltaZ, kZAxisIsSine) * _ZAmplitude * (1-_XZBlend);
            }
            oc.y += offsetFromX  + offsetFromZ;

            o[i].wcPos = mul(unity_ObjectToWorld, float4(oc, 1.0)).xyz; // Get the world space position from ocPos 
            o[i].pcPos = UnityObjectToClipPos(float4(oc, 1.0)); // Recompute the clip space position

            // Normal
            float blendedYOffset = (2 * _XZBlend * deltaX) + (2 * (1-_XZBlend) * deltaZ); // This is kludge! too many conditions to check otherwise
            float3 n = normalize(float3(-heightDeltaX*deltaZ*2, blendedYOffset, -heightDeltaZ*deltaX*2));

            if (ModeIsSet(kDebugShowXHeightChange))
                n = normalize(float3(-heightDeltaX, -heightDeltaX, -heightDeltaX));
            else if (ModeIsSet(kDebugShowZHeightChange))
                n = normalize(float3(-heightDeltaZ, -heightDeltaZ, -heightDeltaZ));
            
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
#endif // EX4_GEOM_SHADER