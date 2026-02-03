using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Assertions.Must;

public class WC_FogControl : MonoBehaviour
{
    public bool DoSingleSample = true;
    [Range(0.0f, 2.0f)]
    public float FogExtinctionCoefficient = 1.0f;  // this is extinction coefficient
    [Range(0.05f, 10)]
    public float FogScattering = 1.0f; // this is scattering coefficient
    public Color FogColor = Color.white;
    
    public Transform V1, V2, V3;

    [Range(0.1f, 5.0f)]
    public float vSampleStepSize = 0.5f; 
    [Range(0, 3)]
    public int NoiseFrequency = 1;
    [Range (0.0f, 1.0f)]
    public float NoiseOffset = 0.25f;  // min noise value
    [Range (0.5f, 2.5f)]
    public float NoiseRange = 0.75f; // noise value range

    public Transform LightPos;

    public enum DebugShowFlag
    {
        DebugOff = 0,
        DebugShowNoVolume = 1,
        DebugShowDepth = 2,
        DebugShowVisibleVolumeDepth = 3,
        DebugShowTrAlongRay = 4,
        DebugShowTrToLight = 5,
        DebugShowObjColorWithFogTr = 6,
        DebugShowFogColor = 7
    };
    public DebugShowFlag DebugFlag = DebugShowFlag.DebugOff;
    
    public Material Single_Sample_Fog = null;
        // Connected to Fog2: single volume sample at the center (if seeing through the volume) 
        //                    or at the visible point in the volume
    public Material Multi_Sample_Fog = null;
        // Connected to Multi-Sample-Fog: taking a sample per-specified distance
    public DepthCamControl DepthCam = null;
    void Start()
    {
        Debug.Assert(Single_Sample_Fog != null);
        Debug.Assert(Multi_Sample_Fog != null);
        Debug.Assert(DepthCam != null);

        Single_Sample_Fog.SetTexture("_DepthTexture", DepthCam.GetDepthTexture());
        Multi_Sample_Fog.SetTexture("_DepthTexture", DepthCam.GetDepthTexture());
    }

    void LoadParametersToMaterial(Material mat)
    {
        // Fog specific
        mat.SetColor("_fogColor", FogColor);
        mat.SetFloat("_extinctionCoefficient", FogExtinctionCoefficient);
        mat.SetFloat("_fogScattering", FogScattering);

        // Camera parameters
        mat.SetFloat("_CameraFOV", Camera.main.fieldOfView * Mathf.Deg2Rad);
        mat.SetFloat("_CameraAspect", Camera.main.aspect);

        // Sphere
        mat.SetVector("V1_center", V1.localPosition);
        mat.SetFloat("V1_radius", V1.localScale.x);

        mat.SetFloat("_vSampleStepSize", vSampleStepSize);


        int f = (int)DebugFlag;
        // Debug.Log("Flag = " + f);
        mat.SetInt("_flag", f);

        mat.SetVector("_FogLightPos", LightPos.localPosition);

        mat.SetInt("_NoiseFrequency", NoiseFrequency);
        mat.SetFloat("_NoiseOffset", NoiseOffset);
        mat.SetFloat("_NoiseRange", NoiseRange);
    }

    void Update()
    {
        if (DoSingleSample)
            LoadParametersToMaterial(Single_Sample_Fog);
        else
            LoadParametersToMaterial(Multi_Sample_Fog);
    }

    void OnRenderImage(RenderTexture src, RenderTexture dst)
    {
        // Graphics.Blit(src, dst);  // simple copying

        if (DoSingleSample)
        {
            Graphics.Blit(src, dst, Single_Sample_Fog);
            // Single volume sample
        }
        else
        {
            Graphics.Blit(src, dst, Multi_Sample_Fog);
            // Multi-samples volume sample
        }
            
    }
}
