using UnityEngine;
[System.Serializable]
public class AxisControl
{
    public bool Show = true;
    public bool ModeIsSine = true;
    [Range(0.1f, 5.0f)] public float Amplitude = 1f;
    [Range(0.1f, 40f)] public float PerPeriodOC = 10f; // OC-size that covers one peroid
                                    // 1 means, 1 OC-unit covers each sinusoidal period
}

public class Sine_Control : MonoBehaviour {
    const uint kXShowHeight = 0x01 << 1; // 
    const uint kZShowHeight = 0x01 << 2; // 

    const uint kXAxisIsSine = 0x01 << 3;  // 0 is sine, 1 is cosine
    const uint kZAxisIsSine = 0x01 << 4;
    
    const uint kDebugNormalShowXHeightDelta = 0x01 << 5;
    const uint kDebugNormalShowZHeightDelta = 0x01 << 6;

    const uint kApplyScreenSpace = 0x01 << 7;
    const uint kApplyOC = 0x01 << 8;
    
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
    public Transform LightInfo_Pt_Dir;
    public UseLightType LightType = UseLightType.ePointLight;
    [Header("EX1: Function Control")]
    public AxisControl X_AxisControl = new AxisControl();
    public AxisControl Z_AxisControl = new AxisControl();
    [Header("EX2: Normal Control")]
    [Range(1f, 20f)] public float NormalApproxDist = 5f;
        // Unit is %of the peroid, 1 would mean to take sample positions from +/- distances that are 1% of the peroid away
        // With the default sine-function, peroid is 2-pi, 1 would mean 0.02-pi-distance away
        //          So, normal approximation for theta will be based on y-values from theta-0.02pi and theta+0.02pi distances away

    [Header("EX3: Shape Controls")]
    [Range(0f, 1f)] public float XZBlend = 0.5f;
    
    [Header("EX5: Tessellation Control")]
    public bool UseScreenSpaceTess = true; // If false, use OC space for tessellation control, which is independent from view and projection. If true, use screen space for tessellation control, which is view dependent.
    [Range(0.5f, 100f)] public float EdgeLength = 50f; // Desired edge length of triangle in screen space. The smaller, the more subdivision.
    public bool UseOCTess = false; // If true, use OC space for tessellation control, which is independent from view and projection. If false, use screen space for tessellation control, which is view dependent.
    [Range(2f, 50f)] public float EdgesPerPeroidOC = 20f; // how many edgesto cover a peroid

    [Header("Fragment Debug Show")]
    public bool DebugShowXHeightDelta = false;
    public bool DebugShowZHeightDelta = false;
    public FragShowMode ShowMode = FragShowMode.eShowUnshadedTexture;
    
    private Material mat;


	// Use this for initialization
	void Start () {
        Debug.Assert(LightInfo_Pt_Dir != null, "Please assign the PointLightPos in inspector!");
        mat = GetComponent<MeshRenderer>().material;
        Debug.Log("Main Camera screen resolution: " + Camera.main.pixelWidth + "x" + Camera.main.pixelHeight);
    }

    // Update is called once per frame
    void Update () {
		uint mode = (uint)ShowMode | (uint)LightType;
        mode |= X_AxisControl.Show ? kXShowHeight : 0;
        mode |= X_AxisControl.ModeIsSine ? kXAxisIsSine : 0;
        mode |= Z_AxisControl.Show ? kZShowHeight : 0;
        mode |= Z_AxisControl.ModeIsSine ? kZAxisIsSine : 0;
        mode |= DebugShowXHeightDelta ? kDebugNormalShowXHeightDelta : 0;
        mode |= DebugShowZHeightDelta ? kDebugNormalShowZHeightDelta : 0;
        mode |= UseScreenSpaceTess ? (uint) kApplyScreenSpace : 0;
        mode |= UseOCTess ? (uint) kApplyOC : 0;

        mat.SetInt("_Flag", (int) mode);

        mat.SetFloat("_XAmplitude", X_AxisControl.Amplitude);
        mat.SetFloat("_ZAmplitude", Z_AxisControl.Amplitude);
        mat.SetFloat("_XPerPeriodOC", X_AxisControl.PerPeriodOC);
        mat.SetFloat("_ZPerPeriodOC", Z_AxisControl.PerPeriodOC);
        mat.SetFloat("_NormalApproxDist", NormalApproxDist);
        mat.SetFloat("_XZBlend", 1.0f-XZBlend);

        mat.SetFloat("_EdgeLength", EdgeLength);
        mat.SetFloat("_ScreenWidth", Camera.main.pixelWidth);
        mat.SetFloat("_ScreenHeight", Camera.main.pixelHeight);
        mat.SetFloat("_EdgesPerPeroidOC", EdgesPerPeroidOC);
        
        if (LightType == UseLightType.eDirectionalLight) {
            mat.SetVector("_LightInfo", LightInfo_Pt_Dir.up);
        } else 
            mat.SetVector("_LightInfo", LightInfo_Pt_Dir.localPosition);
	}
}