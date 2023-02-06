using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShadowCasterLoader : MonoBehaviour
{
    public Transform LightPosition = null;
    public Transform ShadowReceiver = null;

    public Color ShadowColor = Color.gray;
    void Start()
    {
        Debug.Assert(LightPosition != null);
        Debug.Assert(ShadowReceiver != null);
    }

    // Update is called once per frame
    void Update()
    {
        float D = Vector3.Dot(ShadowReceiver.localPosition, ShadowReceiver.up);

        Shader.SetGlobalVector("_LightPos", LightPosition.localPosition);
        Shader.SetGlobalColor("_ShadowColor", ShadowColor);
        Shader.SetGlobalVector("_Normal", ShadowReceiver.up);
        Shader.SetGlobalFloat("_D", D);
    }
}
