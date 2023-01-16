using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MaterialLoader : MonoBehaviour
{
    public float Ka = 0.2f;
    public Color Ambient = new Color(0.1f, 0.1f, 0.1f, 1.0f); 

    // Start is called before the first frame update
    void Start()
    {
    }

    // Update is called once per frame
    void Update()
    {
        // Loads Ka, Kd, Ambient and Diffuse to the shader
        // DO NOT: load Texture to the shader per update: TOO EXPENSIVE!
    }
}
