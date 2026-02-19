using UnityEngine;

public class EX6_TessControl : MonoBehaviour {
    const uint kGeomComputeHeight = 0x01 << 1; // 
    
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
    
    [Header("Screen-Space Tessellation Control")]
    [Range(0.5f, 100f)] public float EdgeLength = 50f; // Desired edge length of triangle in screen space. The smaller, the more subdivision.

    [Header("Height Map Control")]
    public bool ComputeHeight = false;
    [Range(0.01f, 2f)] public float HeightMapStrength = 1f; // Strength of height map displacement
    [Range(0, 10)] public int HeightMapLevel = 1; // Which level to sample for hieht map (0: is the base map, e.g., 9, is 2^9 filtered result)
    [Range(1, 10)] public int NormalApproxMapLevel = 2; // which level to sample for normal approximation    

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
        mode |= ComputeHeight ? kGeomComputeHeight : 0;
        mat.SetInt("_Flag", (int) mode);

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
