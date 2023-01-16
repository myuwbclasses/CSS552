using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;  // for SceneView access, Selection

public class SceneControl : MonoBehaviour
{
    const int kUseTexture = 1;
    const int kCompAmbient = 2;
    const int kCompDiffuse = 4;
    const int kCompSpecular = 8;
    const int kCompDistAtten = 16;
    const int kCompAngularAtten = 32;
    
    private static int kNumLights = 4; // must be identical to the M2_Shader

    public LightSource[] Lights;
    LightsLoader mLgtLoader = new LightsLoader();
    
    void Start()
    {        
    }


    // Update is called once per frame
    void Update()
    {
        // Sets per-scene information
        // Lights
        // Current Camera position
        // Mode: on what is on and off
        // Hint: Set by calling
        //    Shader.SetGlobal ...   
    }
}
