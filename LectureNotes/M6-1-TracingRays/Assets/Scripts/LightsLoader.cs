using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;  // for SceneView access, Selection

public class LightsLoader
{
    const int kNumLights = 4;
    
    float[] mLightState;
    Vector4[]  mLightPosition;
    Vector4[]  mLightDirection;
    Vector4[] mLightColor;
    float[] mLightIntensity;
    float[] mLightNearDist;
    float[] mLightFarDist;
    float[] mSpotInnerCos;  // cosine of the angle!
    float[] mSpotOuterCos;
    float [] mSpotDropOff;
    
    public LightsLoader()
    {
        mLightState = new float [kNumLights];
        mLightPosition = new Vector4[kNumLights];
        mLightDirection = new Vector4[kNumLights];
        mLightColor = new Vector4[kNumLights];
        mLightIntensity = new float[kNumLights];
        mLightNearDist = new float[kNumLights];
        mLightFarDist = new float[kNumLights];
        mSpotInnerCos = new float[kNumLights];
        mSpotOuterCos = new float[kNumLights];
        mSpotDropOff = new float[kNumLights];

        for (int i = 0; i < kNumLights; i++) {
            mLightState[i] = 0.0f;  // this is off
            mLightPosition[i] =  Vector4.zero;
            mLightDirection[i] = Vector4.zero;
            mLightColor[i] = Vector4.zero;
            mLightIntensity[i] = 1.0f;
            mLightNearDist[i] = 0.0f;
            mLightFarDist[i] = 1.0f;
            mSpotInnerCos[i] = Mathf.Cos(10f * Mathf.Deg2Rad);   // half of the angle
            mSpotOuterCos[i] = Mathf.Cos(20f * Mathf.Deg2Rad);
            mSpotDropOff[i] = 2.0f;
        }
    }

    // Update is called once per frame
    public void LoadLightsToShader()
    {
        Shader.SetGlobalFloatArray("LightState", mLightState);

        Shader.SetGlobalVectorArray("LightPosition", mLightPosition);
        
        Shader.SetGlobalVectorArray("LightDirection", mLightDirection);
        
        Shader.SetGlobalVectorArray("LightColor", mLightColor);
        Shader.SetGlobalFloatArray("LightIntensity", mLightIntensity);
        
        Shader.SetGlobalFloatArray("LightNearDist", mLightNearDist);
        Shader.SetGlobalFloatArray("LightFarDist", mLightFarDist);

        Shader.SetGlobalFloatArray("SpotInnerCos", mSpotInnerCos);
        Shader.SetGlobalFloatArray("SpotOuterCos", mSpotOuterCos);

        Shader.SetGlobalFloatArray("SpotDropOff", mSpotDropOff);
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

        mLightPosition[index] = s.transform.localPosition;
        mLightDirection[index] = s.transform.up;

        mLightColor[index] = s.LightColor;
        mLightIntensity[index] = s.Intensity;

        mLightNearDist[index] = s.Near;
        mLightFarDist[index] = s.Far;

        mSpotDropOff[index] = s.SpotDropOff;
        mSpotInnerCos[index] = Mathf.Cos(0.5f * s.SpotInner * Mathf.Deg2Rad);
        mSpotOuterCos[index] = Mathf.Cos(0.5f * s.SpotOuter * Mathf.Deg2Rad);
    }
}
