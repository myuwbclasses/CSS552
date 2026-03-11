using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DepthCamControl : MonoBehaviour
{
    public Shader RT_DepthShader = null;

    private RenderTexture mTextureOfPosition = null;
    private RenderTexture mTextureOfNormal = null;
    private RenderBuffer[] mRenderBuffer;

    // Do this before Start() such that
    // at start time, targetTexture is properly initialized
    void Awake()
    {
        Debug.Assert(RT_DepthShader != null);

        // make sure the render target resolution is the same as the hosting camera
        // https://docs.unity3d.com/ScriptReference/RenderTextureFormat.html
        mTextureOfPosition = new RenderTexture(Camera.main.pixelWidth, Camera.main.pixelHeight, 32, RenderTextureFormat.ARGBFloat);
        mTextureOfPosition.Create();
        mTextureOfNormal   = new RenderTexture(Camera.main.pixelWidth, Camera.main.pixelHeight, 32, RenderTextureFormat.ARGBFloat);
        mTextureOfNormal.Create();
        mRenderBuffer = new RenderBuffer[2];
        mRenderBuffer[0] = mTextureOfPosition.colorBuffer;
        mRenderBuffer[1] = mTextureOfNormal.colorBuffer;

        GetComponent<Camera>().SetTargetBuffers(mRenderBuffer, mTextureOfPosition.depthBuffer);

        // render with depth shader
        GetComponent<Camera>().SetReplacementShader(RT_DepthShader, "RayTracer");
            // all objects that are connect to shaders with "RayTracer" matching
            //           "Reflective"  or  "Regular" 
            // will be rendered with RT_DepthShader by DepthCamera
    }

    // Update is called once per frame
    void Update()
    {
        // These two are defined in the RayFunction.cginc
        Shader.SetGlobalFloat("_CameraFOV", Camera.main.fieldOfView * Mathf.Deg2Rad);
        Shader.SetGlobalFloat("_CameraAspect", Camera.main.aspect);
    }

    public RenderTexture GetPositionTexture() { 
            return mTextureOfPosition;
    }

    public RenderTexture GetNormalTexture()
    {
        return mTextureOfNormal;
    }
}
