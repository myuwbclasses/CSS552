using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LensControl : MonoBehaviour
{
    public float FocalDistant = 5.0f;
    public float Aperture = 2.0f;  // all within this range are in focus
    // for debug support
    public enum DebugShowFlag {
        DebugOff = 0,
        DebugShowInFocus = 1,
        DebugShowFocus_NF = 2,
        DebugShowStages = 4,
        DebugShowBlend = 8
    };
    public DebugShowFlag DebugFlag = DebugShowFlag.DebugOff;
    
    public Material LenseMat = null;
    public DepthCamControl DepthCam = null;
    void Start()
    {
        Debug.Assert(LenseMat != null);
        Debug.Assert(DepthCam != null);

        LenseMat.SetTexture("_DepthTexture", DepthCam.GetDepthTexture());

        float invW = 1.0f/(float)Camera.main.pixelWidth;
        float invH = 1.0f/(float)Camera.main.pixelHeight;
        LenseMat.SetFloat("_invWidth", invW);
        LenseMat.SetFloat("_invHeight", invH);
    }

    void Update() {
        // Fog specific
        LenseMat.SetFloat("_inFocusN", FocalDistant-Aperture);
        LenseMat.SetFloat("_inFocusF", FocalDistant+Aperture);

        int f = (int) DebugFlag;
        // Debug.Log("Flag = " + f);
        LenseMat.SetInt("_lensFlag", f);
    }
    void OnRenderImage(RenderTexture src, RenderTexture dst) {
        // Graphics.Blit(src, dst);  // simple copying
        Graphics.Blit(src, dst, LenseMat);
    }
}
