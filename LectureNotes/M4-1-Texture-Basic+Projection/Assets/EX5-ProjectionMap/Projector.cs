using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Projector : MonoBehaviour
{
    // Assumed:
    // . This script is placed on the gameObject with the geometry
    // . This gameObject has a child with name "ProjectorCam"
    // . ProjectorCam must have a camera for computing projection
    // . This gameObject has a material with float4x4 "_WorldToProjectionNDC"
    Camera mTheProjector;
    Material mProjectionMat = null;
    // Start is called before the first frame update
    void Start()
    {
        Transform child = transform.Find("ProjectorCam");
        Debug.Assert( child != null);
        mTheProjector = child.GetComponent<Camera>();
        mProjectionMat = GetComponent<Renderer>().material;

        Debug.Assert(mTheProjector != null);
        Debug.Assert(mProjectionMat != null);
    }

    // Update is called once per frame
    void Update()
    {
        Matrix4x4 m = mTheProjector.projectionMatrix * mTheProjector.worldToCameraMatrix;
        mProjectionMat.SetMatrix("_WorldToProjectionNDC", m);
    }
}
