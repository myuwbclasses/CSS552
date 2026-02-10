using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DepthCamControl : MonoBehaviour
{
    // for debug showing
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

        
        // render with depth shader
        GetComponent<Camera>().clearFlags = CameraClearFlags.SolidColor;
        GetComponent<Camera>().SetReplacementShader(DepthShader, "RenderType");
            // all objects that are connect to shaders with "RenderType" matching "Opaque" 
            // will be rendered with DepthShader by DepthCamera
    }

    // Update is called once per frame

    public RenderTexture GetDepthTexture() { 
        Debug.Assert(mDepthTexture != null);
        return mDepthTexture; 
    }
}
