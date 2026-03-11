using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class SphereLoader : MonoBehaviour {

    Vector3 OC_PtOn; // Point on sphere in OC space

	void Start ()
    {
        OC_PtOn = new Vector3(transform.localScale.x, 0, 0);
    }

    // Update is called once per frame
    void Update () {
        Vector3 center = transform.localPosition;
        float r = transform.localScale.x * 0.5f;

        Shader.SetGlobalVector("_TheCenter", new Vector4(center.x, center.y, center.z, 1.0f));
        Shader.SetGlobalFloat("_TheRadius", r);

        // Debug.Log("Center:" + center + " Radius: " + r);
	}
}
