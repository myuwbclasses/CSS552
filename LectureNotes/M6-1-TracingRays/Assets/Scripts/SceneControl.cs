using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.Globalization;
using System;
using Unity.VisualScripting;  // for SceneView access, Selection

public class SceneControl : MonoBehaviour
{
    const int kUseTexture = 1;
    const int kCompAmbient = 2;
    const int kCompDiffuse = 4;
    const int kCompSpecular = 8;
    const int kCompDistAtten = 16;
    const int kCompAngularAtten = 32;

    const int kRayTraceShadow = 0x01 << 20;

    public enum RT_DebugShow {
        eShowRegular = 0x0,
        eShowRTObjectInRed = 0x01 << 10,
        eShowRTNormal = 0x01 << 11,
        eShowSphereInBlue = 0x01 << 12,
        eShowTriangleInGreen = 0x01 << 14,
        eShowOnlySphereReflect = 0x01 << 13,
        eShowOnlyTriangleReflect = 0x01 << 15,
    }

    public enum RT_MaterialShow
    {
        eShowRegular = 0x0,
        eShowAmbient = 0x01 << 16,
        eShowDiffuse = 0x01 << 17,
        eShowSpecular = 0x01 << 18,
        eShowReflectivity = 0x01 << 19
    }
        

    private static int kNumLights = 4; // must be identical to the M2_Shader

    [Header("RT Settings")]
    public bool RayTracing = false;
    public bool RayTraceShadow = false;
    [Range(0.05f, 1.0f)] public float RayShadowDarkness = 0.3f;
    public Color RT_BackgroundColor = Color.white;
    public RT_DebugShow RTDebugShow = RT_DebugShow.eShowRegular;
    public RT_MaterialShow RTMaterialShow = RT_MaterialShow.eShowRegular;

    [Header("Phong Material Settings")]
    public bool UseMainCamera = true;
    public bool Texture = true;
    public bool Ambient = true;
    public bool Diffuse = true;
    public bool Specular = true;
    public bool DistanceAttenuation = true;
    public bool AngularAttenuation = true;
    public LightSource[] Lights;
    LightsLoader mLgtLoader = new LightsLoader();

    
    void Start()
    {
        /*  Either this way, or in the editor
        Lights = new LightSource[kNumLights];
        for (int i = 0; i < kNumLights; i++) {
            GameObject g = new GameObject();
            g.name = "Light " + i;
            g.transform.SetParent(transform, false);
            Lights[i] = g.AddComponent<LightSource>();
        }
        */
    }

    void SetLightLoader() {
        for (int i = 0; i < kNumLights; i++)
            mLgtLoader.LightSourceSetLoader(i, Lights[i]);
    }

    // Update is called once per frame
    void Update()
    {   
        // This is NOT light, but per-shader shared for all
        if (UseMainCamera) 
            Shader.SetGlobalVector("_CameraPosition", (Vector4) Camera.main.transform.localPosition);
        else {
            Shader.SetGlobalVector("_CameraPosition", (Vector4) SceneView.lastActiveSceneView.camera.transform.localPosition);
        }
        
        // ShaderMode;
        int mode = (Texture) ? kUseTexture : 0;
        mode |= (Ambient) ? kCompAmbient : 0;
        mode |= (Diffuse) ? kCompDiffuse : 0;
        mode |= (Specular) ? kCompSpecular : 0;
        mode |= (DistanceAttenuation) ? kCompDistAtten : 0;
        mode |= (AngularAttenuation) ? kCompAngularAtten : 0;
        mode |= (RayTraceShadow) ? kRayTraceShadow : 0;

        mode |= (int) RTDebugShow;
        mode |= (int) RTMaterialShow;
        
        Shader.SetGlobalInt("_ShaderMode", mode);
        // Debug.Log("ShaderMode=" + mode);

        SetLightLoader();
        mLgtLoader.LoadLightsToShader();
    }
}
