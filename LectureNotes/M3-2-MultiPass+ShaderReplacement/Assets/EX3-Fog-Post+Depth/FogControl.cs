using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FogControl : MonoBehaviour
{
    public float N = 1;
    public float F = 10;
    public float FogDensity = 1.0f;
    public Color FogColor = Color.white;
    // for debug support
    public enum DebugShowFlag {
        DebugOff = 0,
        
        DebugShowNear = 1,
        
        DebugShowBlend = 2
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
        FogMat.SetFloat("_fogDensity", FogDensity);
        FogMat.SetFloat("_n", N);
        FogMat.SetFloat("_f", F);

        int f = (int) DebugFlag;
        // Debug.Log("Flag = " + f);
        FogMat.SetInt("_flag", f);
    }
    void OnRenderImage(RenderTexture src, RenderTexture dst) {
        // Graphics.Blit(src, dst);  // simple copying
        Graphics.Blit(src, dst, FogMat);
    }
}
