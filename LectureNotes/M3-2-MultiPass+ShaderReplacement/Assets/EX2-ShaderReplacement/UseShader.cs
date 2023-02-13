using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UseShader : MonoBehaviour
{
     public Shader TargetShader = null; // all objects with the specified tag will be rendered using this shader
     public bool SetReplacement = false;

    // Start is called before the first frame update
    void Start()
    {
    }

    // Update is called once per frame
    void Update()
    {
        if (SetReplacement) {
            SetReplacement = false;
            if (TargetShader != null)
                GetComponent<Camera>().SetReplacementShader(TargetShader, "ConstantColor");
            else   
                Debug.Log("WARNING: TargetShader is null!");
        }
    }
}
