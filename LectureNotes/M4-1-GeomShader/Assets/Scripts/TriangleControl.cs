using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TriangleControl : MonoBehaviour {
    [Header("Light Settings")]
    public Transform PointLightPos;
    public enum UseLightType
    {
        eDirectionalLight = 0x01 << 20,
        ePointLight = 0x01 << 21
    }
    public UseLightType LightType = UseLightType.eDirectionalLight;

    public enum GeomComputeMode
    {
        eComputeNothing = 0x01,
        eComputeDivide = 0x02
    };
    [Header("Geom Shader: Divide or not")]
    public GeomComputeMode ComputeMode = GeomComputeMode.eComputeNothing;
    [Range(-0.5f, 0.5f)] public float CenterOffset = 0.1f;
    [Range(-1.0f, 1.0f)] public float NormalOffset = 0.2f;

    public enum ColorAndUVMode
    {
        eUseSimpleAverage = 0x01 << 4, // use the center offset to compute the center point in GS
        eUseBCAlphas = 0x01 << 5
    };
    [Header("Interpoation: BC or Average")]
    public ColorAndUVMode BCMode = ColorAndUVMode.eUseSimpleAverage;
    [Range(-0.5f, 1.5f)] public float Alpha1 = 0.33f;
    [Range(-0.5f, 1.5f)] public float Alpha2 = 0.33f;

    public enum FragShowMode
    {
        eShowShadedTexture = 0x01 << 10,
        eShowUV = 0x01 << 11,
        eShowWCPos = 0x01 << 12,
        eShowNormal = 0x01 << 13,
        eShowLightDir = 0x01 << 14,
        eShowNdotL = 0x01 << 15,
        eShowVertexColor = 0x01 << 16,
        eShowUnshadedTexture = 0x01 << 17
    }
    [Header("Fragment Shader: Show what?")]
    public FragShowMode ShowMode = FragShowMode.eShowShadedTexture;

    private Material mat;


	// Use this for initialization
	void Start () {
        Debug.Assert(PointLightPos != null, "Please assign the PointLightPos in inspector!");
        mat = GetComponent<MeshRenderer>().material;
    }

    // Update is called once per frame
    void Update () {
		uint mode = (uint)ComputeMode | (uint)ShowMode | (uint)LightType | (uint)BCMode;
        // Debug.Log("Current mode: " + mode + ", ComputeMode: " + ComputeMode + ", ShowMode: " + ShowMode);
        mat.SetInt("_Flag", (int) mode);
        mat.SetFloat("_CenterOffset", CenterOffset);
        mat.SetFloat("_NormalOffset", NormalOffset);
        mat.SetFloat("_Alpha1", Alpha1);
        mat.SetFloat("_Alpha2", Alpha2);
        if (LightType == UseLightType.eDirectionalLight) {
            mat.SetVector("_LightPos", -PointLightPos.up);
        } else 
            mat.SetVector("_LightPos", PointLightPos.localPosition);
	}
}
