using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;  // for SceneView access, Selection

public class LightsLoader
{
    const int kNumLights = 4;
    
    float[] mLightState;

    public LightsLoader()
    {
        mLightState = new float [kNumLights];

        for (int i = 0; i < kNumLights; i++) {
            mLightState[i] = 0.0f;  // this is off
        }
    }

    // Update is called once per frame
    public void LoadLightsToShader()
    {
        // You need to define LightState array in the shader
        Shader.SetGlobalFloatArray("LightState", mLightState); 
        
        // Debug.Log("Load shader: mLightPosition:" + mLightPosition.Length + " " + mLightPosition);
        // if you get this error message:
        //      Property (LightPosition) exceeds previous array size (2 vs 1). Cap to previous size. Restart Unity to recreate the arrays.
        // then, you will have to quit and re-start unity. Arrays in the share is _very_ tricky
        //      ref: https://forum.unity.com/threads/shader-setglobalvectorarray-size-is-limited-even-when-list-is-passed.572518/ 
    }

    public void LightSourceSetLoader(int index, LightSource s) {
        if (s.LightIsOn)
            mLightState[index] = (float) s.LightState;
        else
            mLightState[index] = 0.0f;
    }
}
