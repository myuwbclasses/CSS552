using UnityEngine;

[System.Serializable]
public class FogControl
{
    [Header("Fog Position")]
    public Vector2 MinPoint = new Vector2(-10f, -10f);
    public Vector2 MaxPoint = new Vector2(10f, 10f);
    [Header("Fog Options")]
    public Color FogColor = Color.white;    
    [Range(0f, 20f)] public float FogHeight = 5f;
    [Range(0.1f, 2f)] public float FogExtinction = 1f;
    [Range(1f, 10f)] public float FogDropOff = 1f;
    [Range(0.1f, 2f)] public float FogScattering = 1f;
    
    public enum DebugShowFlag {
        DebugOff = 0,
        DebugShowTau = 0x01,
        DebugShowInterval = 0x01 << 1,
        DebugShowTransmittance = 0x01 << 2,
        DebugShowFogColor = 0x01 << 3
    };
    
    [Header("Debug Options")]
    public DebugShowFlag DebugFlag = DebugShowFlag.DebugOff;
    [Header("Configurations")]
    public Material FogMat; //  UI will set these
    public DepthCamControl DepthCam; // 

    public void InitFogControl() {
        FogMat.SetTexture("_DepthTexture", DepthCam.GetDepthTexture());
    }

    public void UpdateFogControl(Camera cam) {
        FogMat.SetVector("_CameraPosition", cam.transform.localPosition);
        FogMat.SetFloat("_CameraFOV", cam.fieldOfView * Mathf.Deg2Rad);
        FogMat.SetFloat("_CameraAspect", cam.aspect);

        FogMat.SetVector("_Min", MinPoint);
        FogMat.SetVector("_Max", MaxPoint);

        // Fog specific
        FogMat.SetFloat("_fogHeight", FogHeight);
        FogMat.SetFloat("_fogExtinction", FogExtinction);

        FogMat.SetFloat("_fogDropOff", FogDropOff);
        FogMat.SetFloat("_fogScattering", FogScattering);
        FogMat.SetColor("_fogColor", FogColor);

        int f = (int) DebugFlag;
        FogMat.SetInt("_flag", f);
    }
}
