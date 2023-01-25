using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class RenderDepth : MonoBehaviour
{
    public Shader DepthShader = null;
    // public Material DepthMat = null;

    // public Transform ParentCamera = null;
    //      In the editor we are a child of ParentCamera (MainCamera), so no need to do anything special
    

    // Renders to the RenderTexture (ZBufferContent)
    // ZBufferContent is the texture for ShowTexture shadder (connected in UI)
    void Start()
    {
        GetComponent<Camera>().SetReplacementShader(DepthShader, "RenderType");
        //GetComponent<Camera>().SetReplacementShader(DepthMat.shader, "RenderType");
            // Renders all shaders with RenderType-tag match the DepthMap.shader
    }

    /*
    void Update() {
        transform.localPosition = ParentCamera.localPosition;
        transform.localRotation = ParentCamera.localRotation;
    }
    */

}
