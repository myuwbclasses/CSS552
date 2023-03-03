using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LightControl : MonoBehaviour
{
    public Transform mTheLight = null;

    public enum eLightType {
        ePointLight = 0,
        eDirectionalLight = 1
    };

    public Color LightColor = Color.white;
    public float Strength = 1.0f;
    
    public eLightType LightType = eLightType.ePointLight;
    public Material mBumpMat = null;


    // Start is called before the first frame update
    void Start()
    {
        Debug.Assert(mTheLight != null);
        Debug.Assert(mBumpMat != null);
    }

    // Update is called once per frame
    void Update()
    {
        mBumpMat.SetVector("_LightColor", LightColor);
        mBumpMat.SetVector("_LightPosition", mTheLight.localPosition);
        mBumpMat.SetVector("_LightDirection",  mTheLight.up);
        mBumpMat.SetFloat("_LightStrength", Strength); 
        mBumpMat.SetInt("_LightType", (int)LightType); 

        mTheLight.gameObject.GetComponent<Renderer>().material.color = LightColor;   
    }
}
