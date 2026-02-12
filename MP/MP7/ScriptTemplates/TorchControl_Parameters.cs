using UnityEngine;

[System.Serializable]
public class TorchControl
{  
    [Header("Torch Visuals")]
    public bool ShowTorchFog = true;
    public bool ShowTorchBlur = true;
    public bool ShowInvertedBlur = false; 
    const int kShowTorchFog = 0x01 << 10;
    const int kShowTorchBlur = 0x01 << 12;
    const int kShowInvertedBlur = 0x01 << 13;

    [Header("Torch Parameters")]
    public Transform TorchPosition = null;
    [Range(1f, 40f)] public float TorchRadius = 5.0f;
    public Color TorchFogColor = Color.white;
    [Header("Torch Illumination Cut Off")]
    [Range(10f, 100f)] public float TorchFar = 10f;
    [Range(0.1f, 2f)] public float TorchFarIntensity = 0.3f;
    
    [Header("Torch Volumetric Parameters")]
    [Range(0f, 1f)] public float TorchExtinction = 0.25f; // how much light is attenuated when ray goes through the torch, in the form of exp(-tau*extinction)
    [Range(1f, 10f)] public float TorchTauDropOff = 5.0f; // how fast the attenuation increases as ray goes deeper into the torch, in the form of pow(tau, dropOff)
    [Range(0.1f, 2f)] public float TorchScattering = 0.5f; // how much light is scattered in the torch region
    
    
    // for debug support
    public enum DebugShowFlag {
        DebugOff = 0,
        DebugShowRegion = 0x01,
        DebugShowTau = 0x01 << 2,
        DebugShowTorchInterval = 0x01 << 3,
        DebugShowTransmittance = 0x01 << 4,
        DebugShowTorchColor = 0x01 << 5
    };
    [Header("Debug Options")]
    public DebugShowFlag DebugFlag = DebugShowFlag.DebugOff;
    [Header("Configurations")]
    public Material TorchMat = null;
    public DepthCamControl DepthCam = null;
    
    public void InitTorchControl()
    {
        TorchMat.SetTexture("_DepthTexture", DepthCam.GetDepthTexture());
    }

    public void UpdateTorchControl(Camera cam) {

        float invW = 1.0f/(float)cam.pixelWidth;
        float invH = 1.0f/(float)cam.pixelHeight;
        TorchMat.SetFloat("_invWidth", invW);
        TorchMat.SetFloat("_invHeight", invH);
        
        TorchMat.SetVector("_CameraPosition", cam.transform.localPosition);
        TorchMat.SetFloat("_CameraFOV", cam.fieldOfView * Mathf.Deg2Rad);
        TorchMat.SetFloat("_CameraAspect", cam.aspect);
        // Debug.Log("CameraFov=" + cam.fieldOfView + ", Aspect=" + cam.aspect);

        TorchMat.SetVector("_torchPosition", TorchPosition.localPosition);
        TorchMat.SetFloat("_torchRadius", TorchRadius);
        TorchMat.SetColor("_torchFogColor", TorchFogColor);
        TorchMat.SetFloat("_torchExtinction", TorchExtinction);
        TorchMat.SetFloat("_torchScattering", TorchScattering);
        TorchMat.SetFloat("_torchTauDropOff", TorchTauDropOff);

        TorchMat.SetFloat("_torchFar", TorchFar);
        TorchMat.SetFloat("_torchFarIntensity", TorchFarIntensity);

        int f = (int) DebugFlag;
        f |= ShowTorchFog ? kShowTorchFog : 0;
        f |= ShowTorchBlur ? kShowTorchBlur : 0;
        f |= ShowInvertedBlur ? kShowInvertedBlur : 0;
        TorchMat.SetInt("_torchFlag", f);
    }

}
