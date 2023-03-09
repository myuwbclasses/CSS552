using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LightControl : MonoBehaviour
{
    public enum eLightType {
        ePointLight = 0,
        eDirectionalLight = 1
    };

    public Color LightColor = Color.white;
    public float Strength = 1.0f;
    
    public eLightType LightType = eLightType.ePointLight;


    // Start is called before the first frame update
    void Start()
    {
    }

    // Update is called once per frame
    void Update()
    {
        Shader.SetGlobalVector("_LightColor", LightColor);
        Shader.SetGlobalVector("_LightPosition", transform.localPosition);
        Shader.SetGlobalVector("_LightDirection",  transform.up);
        Shader.SetGlobalFloat("_LightStrength", Strength); 
        Shader.SetGlobalInt("_LightType", (int)LightType); 

        gameObject.GetComponent<Renderer>().material.color = LightColor;   
    }
}
