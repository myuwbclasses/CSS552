using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LightSource : MonoBehaviour
{
    public Color LightColor = Color.white;
    public bool  LightIsOn = true;

    Material MyMat = null;

    // Start is called before the first frame update
    void Start()
    {        
        MyMat = GetComponent<Renderer>().material;
    }

    void Update() {
        // Updates the _Color on the shader
        if (LightIsOn)
            MyMat.SetColor("_Color", LightColor);
        else
            MyMat.SetColor("_Color", Color.black);
    }

}
