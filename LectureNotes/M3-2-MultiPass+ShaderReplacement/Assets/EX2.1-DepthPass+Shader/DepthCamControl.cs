using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DepthCamControl : MonoBehaviour
{
    // for debug showing
    public float WC_Scale = 10f; 
    public Vector3 WC_Offset = Vector3.zero;
    public enum DepthDebugMode {
        DebugOff = 0,
        DebugShowWCPoint = 1,
        DebugShowDistance = 0x10
    };
    public DepthDebugMode DebugMode = DepthDebugMode.DebugOff;

    public Transform ShowDepthTexture = null;

    public Shader DepthShader = null;

    private RenderTexture mDepthTexture = null;

    // Do this before Start() such that
    // at start time, targetTexture is properly initialized
    void Awake()
    {
        Debug.Assert(DepthShader != null);

        // make sure the render target resolution is the same as the hosting camera
        // https://docs.unity3d.com/ScriptReference/RenderTextureFormat.html
        mDepthTexture = new RenderTexture(Camera.main.pixelWidth, Camera.main.pixelHeight, 32, RenderTextureFormat.ARGBFloat);
                // Says, 32-bit Z-Buffer (for accuracy)
                // Each channel is a 32-bit floating point number!

        GetComponent<Camera>().targetTexture = mDepthTexture;
            // do this in Start() assuming GameWindow size will not change during run time.

        if (ShowDepthTexture != null)   // if this is set, display the depth texture rendered
            ShowDepthTexture.gameObject.GetComponent<Renderer>().material.SetTexture("_MainTex", mDepthTexture);  // this is what we want to see
            // Assume this game object has a material with shader that has "_MainTex"
        
        // render with depth shader
        GetComponent<Camera>().SetReplacementShader(DepthShader, "DepthValue");
            // all objects that are connect to shaders with "DepthValue" matching "InWC" 
            // will be rendered with DepthShader by DepthCamera
    }

    // Update is called once per frame
    void Update()
    {
        Shader.SetGlobalInt("_debugDepth", (int) DebugMode);
        if (DebugMode != DepthDebugMode.DebugOff) {
            Shader.SetGlobalFloat("_wcScale", 1f/WC_Scale);
            Shader.SetGlobalVector("_wcOffset", WC_Offset);
        } 
    }

    public RenderTexture GetDepthTexture() { 
        Debug.Assert(mDepthTexture != null);
        return mDepthTexture; 
    }
}
