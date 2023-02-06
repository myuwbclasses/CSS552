using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShowVector : MonoBehaviour
{
    // KEY: recognize direction of the cylinder is defined by:
    //
    //      transform.up <-- a normalized vector!
    // 
    const float kWidth = 0.25f;
    public float VectorLength = 2f; // initial default length
    public Transform VectorTip = null; // Front of the vector
    public Transform VectorTail = null; // Begin (location) of vector

    private Vector3 mAt = Vector3.zero; 
    public Vector3 VectorAt() { return mAt; } 
    public Vector3 VectorDir()  { return transform.up; }

    // Start is called before the first frame update
    void Start()
    {
        Debug.Assert(VectorTip != null);
        Debug.Assert(VectorTail != null);
    }

    // Update is called once per frame
    void Update()
    {
        transform.localScale = new Vector3(kWidth, 0.5f*VectorLength, kWidth);
        VectorTip.localScale = new Vector3(1.0f, 1.0f/(VectorLength), 1.0f);
        VectorTail.localScale = new Vector3(1.0f, 0.5f/(VectorLength), 1.0f);

        mAt = transform.localPosition - 0.5f * VectorLength * VectorDir();
    }

    public void SetVectorAt(Vector3 p) {
        transform.localPosition = p + 0.5f * VectorLength * VectorDir();
    }

    public void SetVectorDir(Vector3 d) {
        transform.localRotation = Quaternion.FromToRotation(Vector3.up, d);
    }
}

