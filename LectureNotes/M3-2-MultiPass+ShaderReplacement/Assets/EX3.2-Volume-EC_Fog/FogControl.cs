using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FogControl : MonoBehaviour
{
    public float N = 1;
    public float F = 10;

    [Range(0.05f, 1.5f)] 
    public float FogExtinctionCoefficient = 1.0f;  // this is extinction coefficient
    public Color FogColor = Color.white;
    // for debug support

    [Range(0.05f, 10)]
    public float FogScattering = 1.0f; // this is scattering coefficient

    [Range(0.1f, 5f)]
    public float FogHeight = 1.0f; // this is a hack

    public enum DebugShowFlag {
        DebugOff = 0,
        
        DebugHideFog = 0x01 << 1,
        DebugShowDepth = 0x01 << 2,
        DebugShowNearFar = 0x01 << 3,
        DebugShowTransmittance = 0x01 << 4,
        DebugShowFogColor = 0x01 << 5
    };
    public DebugShowFlag DebugFlag = DebugShowFlag.DebugOff;
    
    public Material FogMat = null;
    public DepthCamControl DepthCam = null;
    void Start()
    {
        Debug.Assert(FogMat != null);
        Debug.Assert(DepthCam != null);

        FogMat.SetTexture("_DepthTexture", DepthCam.GetDepthTexture());
    }

    void Update() {
        // Fog specific
        FogMat.SetColor("_fogColor", FogColor);
        FogMat.SetFloat("_extinctionCoefficient", FogExtinctionCoefficient);
        FogMat.SetFloat("_fogScattering", FogScattering);
        FogMat.SetFloat("_n", N);
        FogMat.SetFloat("_f", F);
        FogMat.SetFloat("_fogHeight", FogHeight);

        int f = (int) DebugFlag;
        // Debug.Log("Flag = " + f);
        FogMat.SetInt("_flag", f);
    }
    void OnRenderImage(RenderTexture src, RenderTexture dst) {
        // Graphics.Blit(src, dst);  // simple copying
        Graphics.Blit(src, dst, FogMat);
    }
}
