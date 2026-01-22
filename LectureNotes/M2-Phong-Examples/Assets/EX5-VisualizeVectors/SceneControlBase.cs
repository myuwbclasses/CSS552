using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class SceneControlBase : MonoBehaviour
{
    public Transform LightPosition = null;
    public bool UseMainCamera = true;
    // Start is called before the first frame update
    void Start()
    {
        Debug.Assert(LightPosition != null);
    }

    // Update is called once per frame
    public void Update()
    {
        Shader.SetGlobalVector("_MyLightPos", LightPosition.localPosition);
        if (UseMainCamera)
            Shader.SetGlobalVector("_CameraPos", (Vector4) Camera.main.transform.localPosition);
        else
            Shader.SetGlobalVector("_CameraPos", (Vector4) SceneView.lastActiveSceneView.camera.transform.localPosition);
    }
}
