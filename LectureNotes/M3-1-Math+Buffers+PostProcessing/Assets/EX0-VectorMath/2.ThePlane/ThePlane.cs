using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ThePlane : MonoBehaviour
{
    // Attached to a Cube
    //      Plane Equation:    dot(p, N) - D = 0
    // KEYS:
    //         N = transform.up
    //         D = dot(localPosition, transform.up)
    // 
    public float D; 
    public Vector3 N;
    public ShowVector TheNormal;
    void Start()
    {
    }

    // Update is called once per frame
    void Update()
    {
        D = Vector3.Dot(transform.localPosition, transform.up);
        N = transform.up;
        
        TheNormal.SetVectorAt(transform.localPosition);
        TheNormal.SetVectorDir(N);
    }
}
