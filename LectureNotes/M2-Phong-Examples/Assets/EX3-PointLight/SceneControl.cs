using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SceneControl : MonoBehaviour
{
    // Per-scene flag
    const int kShowTexture = 0x01;
    public bool ShowTexture = true; 

    public Transform LightPosition = null;
    // Start is called before the first frame update
    void Start()
    {
        Debug.Assert(LightPosition != null);
    }

    // Update is called once per frame
    void Update()
    {
        // compute the global render flag
        int flag = 0x0;
        if (ShowTexture) flag |= kShowTexture;

        // global shader update
        Shader.SetGlobalInteger("_Flag", flag);
        Shader.SetGlobalVector("_MyLightPos", LightPosition.localPosition);
    }
}
