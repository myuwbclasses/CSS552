using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SendMyLightPos : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
    }

    // Update is called once per frame
    void Update()
    {
        Shader.SetGlobalVector("_LightPos", transform.localPosition);
        Shader.SetGlobalVector("_LightU", transform.right);
        Shader.SetGlobalVector("_LightV", transform.forward);
    }
}
