using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class MaterialLoader : MonoBehaviour
{
    const string RegularTag = "Regular";
    const string RTTag = "Reflective";

    [Header("Ray Tracing")]
    public bool ToggleRT = false;
    public string CurrentShaderTag = RegularTag;
    [Range(0f,2f)] public float Reflectivity = 0.0f;
    [Header("Ambient")]
    [Range(0f,2f)] public float Ka = 0.2f;
    public Color Ambient = new Color(0.1f, 0.1f, 0.1f, 1.0f); 
    [Header("Diffuse")]
    [Range(0f,2f)] public float Kd = 0.8f;
    public Color Diffuse = new Color(0.6f, 0.8f, 0.7f, 1.0f);
    public Texture2D DiffuseTexture = null;
    [Header("Specular")]
    [Range(0f,2f)] public float Ks = 0.6f;
    public Color Specular = new Color(0.2f, 0.2f, 0.2f, 1.0f);
    public float Specularity = 1f;
    Material mMat = null;

    // Start is called before the first frame update
    void Start()
    {
        mMat = gameObject.GetComponent<MeshRenderer>().material;
        mMat.SetTexture("_MainTex", DiffuseTexture);

        mMat.SetOverrideTag("RayTracer", CurrentShaderTag);
    }

    Vector4 C2f(Color c, float s) {
        return new Vector4(c.r*s, c.g*s, c.b*s, c.a*s);
    }

    // Update is called once per frame
    void Update()
    {
        if (ToggleRT)
        {
            ToggleRT = false;
            if (CurrentShaderTag == RTTag) 
                CurrentShaderTag = RegularTag;
            else
                CurrentShaderTag = RTTag;
            mMat.SetOverrideTag("RayTracer", CurrentShaderTag);
        }
        // Debug.Log("mMat=" + mMat);
        mMat.SetVector("_Ka", C2f(Ambient, Ka));
        mMat.SetVector("_Kd", C2f(Diffuse, Kd));
        mMat.SetVector("_Ks", C2f(Specular, Ks));
        mMat.SetFloat("_Specularity", Specularity);
        mMat.SetFloat("_Reflectivity", Reflectivity);
    }
}
