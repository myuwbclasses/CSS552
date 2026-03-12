using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEditor;
using UnityEngine;

public class RT_PostPassCamControl : MonoBehaviour
{
    public Material RT_PostProcess = null;
    public Material DebugPostProcess = null;

    public bool DebugWithByPass = false;

    public RT_PrePassCamControl PrePassCam = null;
 
    RenderTexture mTempRT = null;

    public Transform RT_Sphere, RT_Triangle;
    public SceneControl RTControl;

    // Start is called before the first frame update
    void Start()
    {
        Debug.Assert(PrePassCam != null);
        RT_PostProcess.SetTexture("_RT_Position", PrePassCam.GetPositionTexture());
        RT_PostProcess.SetTexture("_RT_Normal", PrePassCam.GetNormalTexture());

        // we shouldn't need to do this?
        // DebugPostProcess.SetTexture("_MainTex", Camera.main.targetTexture);
        // RT_PostProcess.SetTexture("_MainTex", Camera.main.targetTexture);
    }

    void Update()
    {
        MaterialLoader sMat = RT_Sphere.gameObject.GetComponent<MaterialLoader>();
        MaterialLoader tMat = RT_Triangle.gameObject.GetComponent<MaterialLoader>();
        
        Vector4[] c = new Vector4[2];

        c[0] = sMat.Ambient * sMat.Ka;
        c[1] = tMat.Ambient * tMat.Ka;
        Shader.SetGlobalVectorArray("_RTKa", c);

        c[0] = sMat.Diffuse * sMat.Kd;
        c[1] = tMat.Diffuse * tMat.Kd;
        Shader.SetGlobalVectorArray("_RTKd", c);
        
        c[0] = sMat.Specular * sMat.Ks;
        c[1] = tMat.Specular * tMat.Ks;
        Shader.SetGlobalVectorArray("_RTKs", c);

        float[] s = new float[2];
        s[0] = sMat.Specularity;
        s[1] = tMat.Specularity;
        Shader.SetGlobalFloatArray("_RTSpecularity", s);

        s[0] = sMat.Reflectivity;
        s[1] = tMat.Reflectivity;
        Shader.SetGlobalFloatArray("_RTReflectivity", s);

        Shader.SetGlobalFloat("_RT_ShadowStrength", RTControl.RayShadowDarkness);
        Shader.SetGlobalColor("_RT_BackgroundColor", RTControl.RT_BackgroundColor);
    }

    void OnRenderImage(RenderTexture src, RenderTexture dst) {
        if (DebugWithByPass || (!RTControl.RayTracing)) {
            // For some reason, we need to do this explicitly!?
            DebugPostProcess.SetTexture("_MainTex", Camera.main.targetTexture);
            Graphics.Blit(src, dst, DebugPostProcess);
        }
        else {
            // For some reason, we need to do this explicitly!?
            RT_PostProcess.SetTexture("_RT_Position", PrePassCam.GetPositionTexture());
            RT_PostProcess.SetTexture("_RT_Normal", PrePassCam.GetNormalTexture());
            RT_PostProcess.SetTexture("_MainTex", Camera.main.targetTexture);
            Graphics.Blit(src, dst, RT_PostProcess);
        }
    }
}
