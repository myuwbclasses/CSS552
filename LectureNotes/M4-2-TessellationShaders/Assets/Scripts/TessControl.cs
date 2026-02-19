using UnityEngine;

public class TessControl : MonoBehaviour {
    const uint kDomainComputeHeight = 0x01 << 0;
    const uint kGeomComputeHeight = 0x01 << 1; // 
    const uint kNormalWithBC = 0x01 << 2; // BC interpolate (or, implicit alternaitve slope approximate)
    public enum FragShowMode
    {
        eShowUnshadedTexture = 0x01 << 10,
        eShowShadedTexture = 0x01 << 11,
        eShowUV = 0x01 << 12,
        eShowNormal = 0x01 << 13,
        eShowLightDir = 0x01 << 14,
        eShowNdotL = 0x01 << 15,
        eShowVertexColor = 0x01 << 16
    }

    public enum UseLightType
    {
        eDirectionalLight = 0x01 << 20,
        ePointLight = 0x01 << 21
    }
    
    
    [Header("Light Position/Direction")]
    public Transform PointLightPos;
    public UseLightType LightType = UseLightType.ePointLight;
    [Header("EX1: Hull Shader Control")]
    public bool HullOffset = false; // Whether to offset the hull points along normal direction. 
    [Range(0f, 15f)] public float HullOffsetAmount = 0.1f; // How much to offset the hull points along normal direction. Range between 0 and 1, where 1 means offset by the length of normal vector.
    const uint kHullOffsetFlag = 0x01 << 5; // The flag to indicate whether to offset the hull points along normal direction. This is defined in TessControlFlags.cginc, and should be consistent with the shader code.

    [Header("EX1 + 2: Hard Coded Tessellation Control")]
    [Range(0, 64)] public float PatchEdge = 1f; // How much to subdivide the triangle edges, range between 1 to 64 (or 0 to 64?)
    [Range(0, 20)] public float PatchInside = 1f; // How much to subdivide the triangle: range about 2^ of PatchFactor. For example, if PatchFactor is 4, then PatchInside can be 1, 2, 4, 8, 16 or 32 for different subdivision pattern.

    [Header("EX2, 3, 4: Height Map Control")]
    public bool DomainComputeHeight = false; // Whether to compute height in domain shader or not.
    [Range(0.01f, 2f)] public float HeightMapStrength = 1f; // Strength of height map displacement
    [Range(0, 10)] public int HeightMapLevel = 1; // Which level to sample for hieht map (0: is the base map, e.g., 9, is 2^9 filtered result)
    public bool NormalApproxWithBC = true; //compute normal with barycentric interpolation or with slope approximation when doing height map.
    [Range(1, 10)] public int NormalApproxMapLevel = 2; // which level to sample for normal approximation

    [Header("EX3 + 4: Screen-Space Tessellation Control")]
    [Range(0.5f, 100f)] public float EdgeLength = 50f; // Desired edge length of triangle in screen space. The smaller, the more subdivision.

    [Header("EX5: Geometry Shader Control")]
    public bool GeomComputeHeight = false;

    [Header("Fragment Debug Show")]
    public FragShowMode ShowMode = FragShowMode.eShowUnshadedTexture;
    
    private Material mat;


	// Use this for initialization
	void Start () {
        Debug.Assert(PointLightPos != null, "Please assign the PointLightPos in inspector!");
        mat = GetComponent<MeshRenderer>().material;
        Debug.Log("Main Camera screen resolution: " + Camera.main.pixelWidth + "x" + Camera.main.pixelHeight);
    }

    // Update is called once per frame
    void Update () {
		uint mode = (uint)ShowMode | (uint)LightType;
        mode |= HullOffset ? kHullOffsetFlag : 0;
        mode |= NormalApproxWithBC ? kNormalWithBC : 0;
        mode |= DomainComputeHeight ? kDomainComputeHeight : 0;
        mode |= GeomComputeHeight ? kGeomComputeHeight : 0;

        mat.SetInt("_Flag", (int) mode);

        mat.SetFloat("_HullOffsetAmount", HullOffsetAmount);

        mat.SetFloat("_PatchEdge", PatchEdge);
        // Debug.Log("PatchEdge: " + PatchEdge);
        mat.SetFloat("_PatchInside", PatchInside);

        mat.SetFloat("_HeightMapStrength", HeightMapStrength);
        mat.SetInt("_HeightMapLevel", HeightMapLevel);
        mat.SetInt("_NormalApproxMapLevel", NormalApproxMapLevel);

        mat.SetFloat("_EdgeLength", EdgeLength);
        mat.SetFloat("_ScreenWidth", Camera.main.pixelWidth);
        mat.SetFloat("_ScreenHeight", Camera.main.pixelHeight);
        
        if (LightType == UseLightType.eDirectionalLight) {
            mat.SetVector("_LightInfo", PointLightPos.up);
        } else 
            mat.SetVector("_LightInfo", PointLightPos.localPosition);
	}
}
