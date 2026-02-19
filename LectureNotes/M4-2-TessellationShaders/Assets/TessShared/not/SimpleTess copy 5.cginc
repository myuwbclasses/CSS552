Shader"Custom/SimpleTess"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _LightDir ("Light Dir", Vector) = (0, 11, 0, 1)
        _PatchFactor ("Patch Factor", Float) = 1
        _PatchInside ("Patch Inside", Float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Pass
        {
            Cull Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma hull hull
            #pragma domain domain
            #pragma geometry geom
            #pragma fragment frag

            #pragma target 5.0

            #include "UnityCG.cginc"
            #include "./SimpleTessStruct.cginc"

            uint _Flag;
            uniform float _PatchFactor; // How much to subdivide the triangle patch, range between 1 to 64 (or 0 to 64?)
            uniform float _PatchInside; // How much to subdivide the triangle: range about 2^ of
            float3 _LightPos;
            sampler2D _MainTex;

            #define ModeIsSet(flag) ((_Flag & flag) != 0)

            static const uint kGeomComputeNothing = 0x01;
            static const uint kGeomComputeDivide = 0x02;

            static const uint kShowShadedTexture = 0x01 << 10;
            static const uint kShowUV = 0x01 << 11;
            static const uint kShowNormal = 0x01 << 12;
            static const uint kShowLightDir = 0x01 << 13;
            static const uint kShowNdotL = 0x01 << 14;
            static const uint kShowVertexColor = 0x01 << 15;
            static const uint kShowUnshadedTexture = 0x01 << 16;

            static const uint kUseDirectionalLight = 0x01 << 20;
            static const uint kUsePointLight = 0x01 << 21;


            // Vertex Shader
            // For now, does not do anything! Simply forward information
            // Assumption: all computation will be done in OC space
            Vert2Hull vert(appdata v)
            {
                Vert2Hull o;
                o.vertex = v.vertex;
                o.normal = v.normal;
                o.uv = v.uv; // TRANSFORM_TEX(v.uv, _MainTex);
                o.uv1 = v.uv1; // TRANSFORM_TEX(v.uv1, _HgtTex);
                o.color = v.color;

                // For an actual application, the vert() function would need to
                // Compute parameters that can guide the tessellation process
                // to be associated with each vertex such that the Hull program 
                // can use those parameters in subsequent staages to compute the 
                // tessellation factors and the control points

                return o;
            }

            
            // The [] denotes the attributes of the shader stage function
            //
            // Hull Shader
            [domain("tri")]  // What is the input/output from Domain: tri, quad, isoline
                // tri: domain shader is invoked for each triangle patch, and the input patch is always 3 control points
                // quad: domain shader is invoked for each quad patch, and the input patch is always 4 control points
                // isoline: domain shader is invoked for each isoline patch, and the input patch is always 2 control points

            [partitioning("integer")] // subdivision mode along the edge: fractional_odd, fractional_even, integer, pow2
                // Integer: each edge is subdivided into a whole number of segments, 
                //      independent of the other edges. 
                //      This is the most common subdivision mode.
                // Pow2: each edge is subdivided into a power-of-two number of segments, independent of the other edges.    
                // Odd: each edge is always subdivided into an odd number of segments, 
                //      so that the middle vertex is always on the edge midpoint. 
                // Even: each edge is always subdivided into an even number of segments, 
                //      so that no vertex is generated on the edge midpoint. 
                
            [outputtopology("triangle_cw")]  // Triangle output ordering: not optional!
                // Options: triangle_cw, triangle_ccw, line_adjacency, point

            [patchconstantfunc("ComputeTessFactor")] // Patch constant function
                // Function name for computing the TessFactor based on a input triangle (or patch)

            [outputcontrolpoints(3)] // Number of control points to emit by the hull shader
                // Typically 3 for tri domain, 4 for quad domain
                
    
            // The Hull shader is invoked for each control point in the input patch, 
            // and the output is the control point information to be used by the domain shader
            // Note: input 3-control Points, and return is just 1 of the control points
            // So the job of the Hull Shder is to compute the control point information 
            // based on the input, the results will be used for interpolating the tessellation 
            // results in the domain shader
            OutputFromHull hull(InputPatch<Vert2Hull, 3> points, 
                                 uint id : SV_OutputControlPointID) // Which vertex of the 3-point patch is this control point shader invoked for
            {                
                // For now, let's not do anything
                OutputFromHull o; 
                o.uv = points[id].uv;
                o.uv1 = points[id].uv1;
                o.vertex = points[id].vertex;
                o.normal = points[id].normal;
                o.color = points[id].color;

                // id: 0, 1, 2 for tri patch
                // For an actual application, the hull() function would need to
                // Compute the control points for the domain shader,
                // which can be different from the input vertices
                // 
                // Different from vert(), here, we have access to all three of the vertices
                if (id == 0) {
                    // For example, we can move the control point along the normal direction
                    o.vertex.xyz += 0.5 * o.normal;
                }

                return o;
            }

            // Patch Constant Function: 
            // This function is invoked once per patch, and the input is the control points of the patch (from Hull Shader), 
            // and the output is the tessellation factors for this patch, 
            // Based on these factors, the actual tessellation will be performed by the GPU 
            // (results are in the form of barycentric coordinates of the generated vertices),
            // and the results will be passed to the domain shader for interpolation
            TessFactor ComputeTessFactor(InputPatch<Vert2Hull, 3> points)
            {
                TessFactor o;
                o.edges[0] = _PatchFactor; // How much to subdivide the triangle patch, range between 1 to 64 (or 0 to 64?)
                o.edges[1] = _PatchFactor;
                o.edges[2] = _PatchFactor;
                o.inside = _PatchInside;     // This is triangle density, the number of triangles generated is approx (inside)^2
                return o;
            }

            
            // Domain Shader
            [domain("tri")] // Outputs triangle
            // Our job is to compute the Information to be passed to Fragment shader
            Domain2Frag domain(TessFactor i, // Results from the ComputeTessFactor function
                    const OutputPatch<OutputFromHull, 3> cp, // Control points from the Hull shader
                    float3 bary : SV_DomainLocation) // Barycentric coordinates of the generated vertex
            {
                Domain2Frag o;

                // Texture coordinate                
                o.uv = BCInterpolate(cp[0].uv, cp[1].uv, cp[2].uv, bary);
                o.uv1 = BCInterpolate(cp[0].uv1, cp[1].uv1, cp[2].uv1, bary);
                o.color = BCInterpolate(cp[0].color, cp[1].color, cp[2].color, bary);

                // Vertex position
                float4 oc = BCInterpolate(cp[0].vertex, cp[1].vertex, cp[2].vertex, bary);
                o.pos = UnityObjectToClipPos(oc);
                o.worldPos = mul(unity_ObjectToWorld, oc).xyz;

                // Normal
                float3 ocNormal = BCInterpolate(cp[0].normal, cp[1].normal, cp[2].normal, bary);
                o.worldNormal = normalize(mul(ocNormal, (float3x3)unity_WorldToObject));

                return o;
            }


            // Geometry Shader: CANNOT change the input/ouput data type!!
            [maxvertexcount(9)]  // is this max number of vertices that geom can generate
            void geom(triangle Domain2Frag input[3], inout TriangleStream<Domain2Frag> triStream)
            {
                // in OC: capture the center of the triangle, and normal of the triangle
                float3 center = (input[0].worldPos + input[1].worldPos + input[2].worldPos) / 3.0;
                float3 normal = (input[0].worldNormal + input[1].worldNormal + input[2].worldNormal) / 3.0;
                    
                Domain2Frag quad[4];
                for (int i = 0; i < 3; i++) {
                    quad[i] = input[i];
                }
                    
                if (ModeIsSet(kGeomComputeNothing)) { // show center point as a small quad
                    triStream.Append(quad[0]);
                    triStream.Append(quad[1]);
                    triStream.Append(quad[2]);
                    triStream.RestartStrip();
                } else { 
                    quad[3].pos = UnityObjectToClipPos(center);
                    quad[3].uv = (input[0].uv + input[1].uv + input[2].uv) / 3.0; 
                    quad[3].uv1 = (input[0].uv1 + input[1].uv1 + input[2].uv1) / 3.0;   
                    quad[3].worldPos = center;
                    quad[3].worldNormal = normal;
                    quad[3].color = (input[0].color + input[1].color + input[2].color) / 3.0;

                    triStream.Append(quad[0]);
                    triStream.Append(quad[1]);
                    triStream.Append(quad[3]);
                    triStream.RestartStrip();

                    triStream.Append(quad[3]);
                    triStream.Append(quad[1]);
                    triStream.Append(quad[2]);
                    triStream.RestartStrip();

                    triStream.Append(quad[0]);
                    triStream.Append(quad[3]);
                    triStream.Append(quad[2]);
                    triStream.RestartStrip();
                }
            }

            // Fragment Shader
            float4 frag(Domain2Frag i) : SV_Target
            {
                // directional light direction
                float3 lightDir = normalize(_LightPos - i.worldPos); // in WC, and point light
                if (ModeIsSet(kUseDirectionalLight)) {
                    lightDir = normalize(_LightPos); // in WC, and directional light
                }
                // conpute diffuse
                float diff = max(dot(i.worldNormal, lightDir), 0.0);
                float4 texColor = tex2D(_MainTex, i.uv);
                if (ModeIsSet(kShowShadedTexture))
                    return texColor * diff;
                if (ModeIsSet(kShowUV))
                    return float4(i.uv, 0.0, 1.0);
                if (ModeIsSet(kShowNormal))
                    return float4(i.worldNormal, 1.0);
                if (ModeIsSet(kShowLightDir))
                    return float4(lightDir, 1.0);
                if (ModeIsSet(kShowNdotL))
                    return float4(diff, diff, diff, 1.0);
                if (ModeIsSet(kShowVertexColor))
                    return i.color;
                if (ModeIsSet(kShowUnshadedTexture))
                    return texColor;
                
                return float4(1.0, 0.0, 0.0, 1.0); // What is going on?
            }
            ENDCG
        }
    }
}
