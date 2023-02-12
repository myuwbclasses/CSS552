using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FogSetup : MonoBehaviour
{
    public float WCScale = 2.0f;
    public float N = 1;
    public float F = 10;
    public float FogDensity = 1.0f;
    public Color FogColor = Color.white;
    // for debug support
    public enum DebugShowFlag {
        DebugOff = 0,
        DebugShowNear = 1,
        DebugShowDistance = 2,
        DebugShowBlend = 4
    };
    public DebugShowFlag DebugFlag = DebugShowFlag.DebugOff;
    
    public Material FogMat = null;
    void Start()
    {
        Debug.Assert(FogMat != null);
        Camera.main.depthTextureMode = DepthTextureMode.Depth;
            // https://docs.unity3d.com/Manual/SL-CameraDepthTexture.html
            // this means, the Sampler
            //      _CameraDepthTexture 
            // will be defined for shader access
            // Since we are switching on the Camera.main texture, 
            //     results only visible in the GameWindow
            // 
    }

    void Update() {

        FogMat.SetFloat("_wcScale", WCScale);

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
        // Graphics.Blit(src, dst);  simple copying
        Graphics.Blit(src, dst, FogMat);
    }
}
