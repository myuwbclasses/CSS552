using System.Collections;
using System.Collections.Generic;
using UnityEngine;

// Assume
//     1. This script is attached to ShadowCam
//     2. ShadowCam is a child of the light source
//     3. Initial direction of the camera is pointing in the correct direction
public class ShadowCamControl : MonoBehaviour
{
    public enum DebugShadowMap {
        eDebugOff = 0x0,
        eFilter3 = 0x40,
        eFilter5 = 0x80,
        eFilter9 = 0x100,
        eFilter15 = 0x200,
        eDebugMapDistance = 0x01,
        eDebugMapDistanceWithBias = 0x02,
        eDebugLightDistance = 0x04
    };

    public Shader DepthShader = null;  // Material that computes ShadowMap or DepthMap
    public float DepthBias = 0.1f;  // 
    public float NormalBias = 0.1f;
    public DebugShadowMap DebugFlag = DebugShadowMap.eDebugOff;
    public float DebugDistanceScale = 0.1f;
    
    public Material ShadowMapDiffuse;
    public GameObject ShowDepthTexture = null;

    Camera mShadowCam;
    RenderTexture mDepthTexture;

    public bool Analyze = false;

    // Start is called before the first frame update
    void Start()
    {
        Debug.Assert(DepthShader != null);

        /*** IMPORTANT ***/
        // Set Camera's clearFlag to SolidColor!
        // FOV is 120, larger to cover more space

        mDepthTexture = new RenderTexture(2048, 2048, 32, RenderTextureFormat.ARGBFloat);
                // Unlike previously, this camera is not related to the MainCamera! 2048x2048 is pretty high res
                // Says, 32-bit Z-Buffer (for accuracy)
                // Each channel is a 32-bit floating point number!
                
         if (ShowDepthTexture != null)   // if this is set, display the depth texture rendered
            ShowDepthTexture.GetComponent<Renderer>().material.SetTexture("_MainTex", mDepthTexture);  // this is what we want to see
            // Assume this game object has a material with shader that has "_MainTex"

        mShadowCam = GetComponent<Camera>();
        mShadowCam.SetReplacementShader(DepthShader, "RenderType");    
                        // Any RenderType == "opaque", we can cast shadow
                        // remember, results are in actual world space distance

        mShadowCam.targetTexture = mDepthTexture;
            // do this in Start() assuming GameWindow size will not change during run time.
        ShadowMapDiffuse.SetTexture("_ShadowMap", mDepthTexture);
    }

    // Update is called once per frame
    void Update()
    {   
        Matrix4x4 m = mShadowCam.projectionMatrix * mShadowCam.worldToCameraMatrix;
        ShadowMapDiffuse.SetMatrix("_WorldToLightNDC", m);
        ShadowMapDiffuse.SetFloat("_DepthBias", DepthBias);
        ShadowMapDiffuse.SetFloat("_NormalBias", NormalBias);
        ShadowMapDiffuse.SetFloat("_DebugDistScale", DebugDistanceScale);
        
        ShadowMapDiffuse.SetInteger("_MapFlag", (int) DebugFlag);
    }

    public RenderTexture GetDepthTexture() { 
        Debug.Assert(mDepthTexture != null);
        return mDepthTexture; 
    }
}
