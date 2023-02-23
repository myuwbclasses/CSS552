using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MirrorCamControl : MonoBehaviour
{
    // Assumed attached to the MirrorCam
    public Camera ActualCam = null;
    public Transform TheMirror = null;

    public Shader MirrorDrawShader = null;
        // Mirror cam will use this shader to draw everything!

    RenderTexture mMirrorRT = null;

    // Start is called before the first frame update
    void Awake()
    {
        Debug.Assert(ActualCam != null);
        Debug.Assert(TheMirror != null);

        // will be combined with the ActualCam, so, must be exact same size
        mMirrorRT = new RenderTexture(ActualCam.pixelWidth, ActualCam.pixelHeight, 24);

        // Sets the render target, and replacement shader
        Camera mirrorCam = GetComponent<Camera>();
        mirrorCam.targetTexture = mMirrorRT;
        mirrorCam.SetReplacementShader(MirrorDrawShader, "MyReflection");
    }

    // Update is called once per frame
    void Update()
    {   
        Vector3 p = Vector3.zero;
        Vector3 camAt = ActualCam.transform.localPosition; // camera position
        Vector3 camV = ActualCam.transform.forward; // camera viewing direction
        float dist = LinePlaneIntersect(camAt, camV, TheMirror, out p);
        if (dist < 0f) {
                // not sure what to do, just stop updating the mirror
                return;               
        }

        // 1. Mirror cam is the mirror of the MainCamera
        //    Refer to EX1.4 (MirrorLine.cs) of M3-1 on Mirror!
        Vector3 r = Vector3.Reflect(camV, TheMirror.up);
        
        transform.localPosition = p - dist * r;
        transform.LookAt(p);
    }

    public RenderTexture GetMirrorRT() { return mMirrorRT; }

    // This is from M3-1, EX1.4
    public static float LinePlaneIntersect(Vector3 at, Vector3 V, Transform plane, out Vector3 p) {
        // ALine: at + t * V
        // APlane: dot(plane.up, plane.localPosition) = D
        // 
        // or   dot(N, VectorAt)   +   dot(N, t*VectorDir) = D
        //      t = (D -  dot(N, VectorAt)) / dot(N, VectorDir)
        //
        // NOTE: when N is perpendicular to VectorDir, 
        //          dot(N,VectorDir) = 0
        //       line cannot intersect plane
        float D = Vector3.Dot(plane.up, plane.localPosition);
        p = Vector3.zero;

        float nDotDir = Vector3.Dot(plane.up, V);
        if (Mathf.Abs(nDotDir) < float.Epsilon) {
            // line almost in the same direction as the plane
            // OR: line almost perpendicular to plane normal
            return -1f;
        }
        
        float t = (D - Vector3.Dot(plane.up, at)) * (1.0f/nDotDir);
        p = at + t * V;
        return t; 
        // Note: this intersection is with an infinitely long line starting at, and an infinite-size plane
    }
}
