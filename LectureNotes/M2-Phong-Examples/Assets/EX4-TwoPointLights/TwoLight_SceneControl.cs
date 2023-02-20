using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;  // for SceneView access, Selection

public class TwoLight_SceneControl : MonoBehaviour
{
    // Per-scene flag
    const int kShowTexture = 0x01;
    public bool ShowTexture = true; 

    public LightSource[] AllLights = null;  // will setup in the Editor
        // Array size MUST match MAX_LIGHTS defined in the shader!
    public enum EnumSelectLightPosition {
        ePointLightPosition,
        eMainCameraPosition,
        eEditorCameraPosition
    };
    public EnumSelectLightPosition LightPosFrom = EnumSelectLightPosition.ePointLightPosition;

    Vector4[] LightPosBuffer; // for sending light position to the shader
    float[] LightSwitchBuffer; // for sending light on/off switch to the shader
    Vector4[] LightColorBuffer;
    void Start()
    {
        Debug.Assert(AllLights != null);

        LightPosBuffer = new Vector4[AllLights.Length];
        LightSwitchBuffer = new float[AllLights.Length];
        LightColorBuffer = new Vector4[AllLights.Length];
    }

    // Update is called once per frame
    void Update()
    {
        // compute the global render flag
        int flag = 0x0;
        if (ShowTexture) flag |= kShowTexture;

        // global shader update
        Shader.SetGlobalInteger("_Flag", flag);

        // On/Off Switch
        for (int i = 0; i < AllLights.Length; i++)
            // copy from light source to the buffers
            LightSwitchBuffer[i] = AllLights[i].LightIsOn ? 1.0f : 0.0f;
        Shader.SetGlobalFloatArray("_MyLightFlag", LightSwitchBuffer);

        for (int i = 0; i < AllLights.Length; i++)
            LightColorBuffer[i] = AllLights[i].LightColor;  // notice Color is also a Vector4
        Shader.SetGlobalVectorArray("_MyLightColor", LightColorBuffer);

        // Light position: show we can use the Editor Camera Position!
        for (int i = 0; i < AllLights.Length; i++)
            LightPosBuffer[i] = AllLights[i].transform.localPosition;
        switch (LightPosFrom) { 
            case EnumSelectLightPosition.eMainCameraPosition:
                LightPosBuffer[0] = Camera.main.transform.localPosition;
                break;
            case EnumSelectLightPosition.eEditorCameraPosition: 
                LightPosBuffer[0] = SceneView.lastActiveSceneView.camera.transform.localPosition;
                break;
            // case EnumSelectLightPosition.ePointLightPosition: no need to do anything
        }
        Shader.SetGlobalVectorArray("_MyLightPosition", LightPosBuffer);
        
    }
}
