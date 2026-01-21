using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class VizControl : MonoBehaviour
{
    public enum VisToShow
    {
        eShow_V = 1 << 0,
        eShow_L = 1 << 1,
        eShow_N = 1 << 2,
        eShow_H = 1 << 3,
        eShow_NL = 1 << 4,
        eShow_NH = 1 << 5,
        eShow_VH = 1 << 6,
        eShow_NV = 1 << 7,
        eShow_NHNV= 1 << 8,
        eShow_NHNL = 1 << 9          
    };
    public VisToShow ToShow = VisToShow.eShow_V;
    public Transform LightPosition = null;
    public bool UseMainCamera = true;
    // Start is called before the first frame update
    void Start()
    {
        Debug.Assert(LightPosition != null);
    }

    // Update is called once per frame
    void Update()
    {
        // compute the global render flag
        int flag = (int) ToShow;
        // Debug.Log("flag =" + flag);
        // global shader update
        Shader.SetGlobalInteger("_Flag", flag);
        Shader.SetGlobalVector("_MyLightPos", LightPosition.localPosition);
        if (UseMainCamera)
            Shader.SetGlobalVector("_CameraPos", (Vector4) Camera.main.transform.localPosition);
        else
            Shader.SetGlobalVector("_CameraPos", (Vector4) SceneView.lastActiveSceneView.camera.transform.localPosition);
    }
}
