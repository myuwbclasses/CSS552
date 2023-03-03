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
    const int kFlipBlend = 0x004;
    public enum FogTypeEnum {
        UniformFog = 0x10000,
        PerlinFog = 0x20000,
        FractalFog = 0x40000
    };
    public FogTypeEnum FogType = FogTypeEnum.UniformFog;
    public int SamplesInVolume = 1;

    public DebugShowFlag DebugFlag = DebugShowFlag.DebugOff;
    public bool FlipBlend = false;
    
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

        SamplesInVolume = Mathf.Clamp(SamplesInVolume, 1, 31);

        int f = (int) DebugFlag;
        f |= FlipBlend ? kFlipBlend : 0;
        f |= (int) FogType;
        f |= (SamplesInVolume << 4);
        // Debug.Log("Flag = " + f.ToString("x"));
        FogMat.SetInteger("_flag", f);
    }
    void OnRenderImage(RenderTexture src, RenderTexture dst) {
        // Graphics.Blit(src, dst);  // simple copying
        Graphics.Blit(src, dst, FogMat);
    }
}
