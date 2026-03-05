using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FogControl : MonoBehaviour
{
    public enum FogTypeEnum {
        UniformFog = 0x01 << 10,
        PerlinFog = 0x01 << 11,
        FractalFog = 0x01 << 12
    };
    public enum DebugShowFlag {
        DebugOff = 0,
        DebugShowTau = 0x01 << 1,
        DebugShowInterval = 0x01 << 2,
        DebugShowTransmittance = 0x01 << 3,
        DebugShowFogColor = 0x01 << 4
    };
    
    [Header("Fog Location/Size and Type")]
    public Transform FogGeom;
    public FogTypeEnum FogType = FogTypeEnum.UniformFog;
    
    [Header("Fog Options")]
    public Color FogColor = Color.white;    
    [Range(0.1f, 2f)] public float FogExtinction = 1f;
    [Range(1f, 10f)] public float FogDropOff = 1f;
    [Range(0.1f, 2f)] public float FogScattering = 1f;
        
    [Header("Debug Options")]
    public DebugShowFlag DebugFlag = DebugShowFlag.DebugOff;
    [Header("Configurations")]
    public Material FogMat; //  UI will set these
    public DepthCamControl DepthCam; // 

    void Start() {
        Debug.Assert(FogMat != null);
        Debug.Assert(DepthCam != null);
        FogMat.SetTexture("_DepthTexture", DepthCam.GetDepthTexture());
    }

    void Update() {
        int f = (int) DebugFlag | (int) FogType;
        FogMat.SetInteger("_flag", f);

        Camera cam = Camera.main;
        FogMat.SetVector("_CameraPosition", cam.transform.localPosition);
        FogMat.SetFloat("_CameraFOV", cam.fieldOfView * Mathf.Deg2Rad);
        FogMat.SetFloat("_CameraAspect", cam.aspect);

        // Fog Geom
        FogMat.SetVector("_fogPosition", FogGeom.position);
        FogMat.SetFloat("_fogRadius", FogGeom.localScale.x * 0.5f);
        // Fog specific
        FogMat.SetColor("_fogColor", FogColor);
        FogMat.SetFloat("_fogExtinction", FogExtinction);
        FogMat.SetFloat("_fogDropOff", FogDropOff);
        FogMat.SetFloat("_fogScattering", FogScattering);

    }
    void OnRenderImage(RenderTexture src, RenderTexture dst) {
        // Graphics.Blit(src, dst);  // simple copying
        Graphics.Blit(src, dst, FogMat);
    }
}
