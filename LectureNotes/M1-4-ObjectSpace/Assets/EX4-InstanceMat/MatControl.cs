using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MatControl : MonoBehaviour
{
    public Material GlobalMaterial = null;

    public int GlobalClampFlag = 0x01;
    public float GlobalClampValue = 0.8f;
    public Color GlobalColor = Color.gray;

    public float MyClampValue = 0.8f;
    public Color MyColor = Color.red;
    private Material MyMaterial = null;

    // Start is called before the first frame update
    void Start()
    {
        // Debug.Assert(GlobalMaterial != null);
        // WATCH-it! Cannot have more than one reference to the global!

        MyMaterial = GetComponent<Renderer>().material;  // this will cause instancing!
    }

    // Update is called once per frame
    void Update()
    {
        // Change global
        if (GlobalMaterial != null)  {
            GlobalMaterial.SetFloat("_ClampValue", GlobalClampValue);
            GlobalMaterial.SetColor("_Color", GlobalColor); // Can set variable not via Property

            Shader.SetGlobalInteger("_ClampFlag", GlobalClampFlag);
        }

        // Change my own
        MyMaterial.SetFloat("_ClampValue", MyClampValue);
        MyMaterial.SetColor("_Color", MyColor);
        
    }
}
