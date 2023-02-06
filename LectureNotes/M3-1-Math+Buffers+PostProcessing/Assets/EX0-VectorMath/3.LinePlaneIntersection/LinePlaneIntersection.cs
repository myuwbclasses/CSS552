using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LinePlaneIntersection : MonoBehaviour
{
    public ShowVector ALine = null;
    public ThePlane APlane = null;

    void Start()
    {
        Debug.Assert(ALine != null);
        Debug.Assert(APlane != null);
    }

    // Update is called once per frame
    void Update()
    {
        Color c = Color.black;
        
        transform.localPosition = LinePlaneIntersection.LinePlaneIntersect(APlane, ALine, out c);
        GetComponent<Renderer>().material.color = c;
    }

    public static Vector3 LinePlaneIntersect(ThePlane p, ShowVector l, out Color c) {
        // ALine: VectorAt + t * VectorDir
        // APlane: dot(N, P) - D = 0
        //
        // intersection position is when P is on the line:
        //
        //      dot( N, (VectorAt + t * VectorDir)) - D = 0
        //
        // solve for t:
        // 
        // or   dot(N, VectorAt)   +   dot(N, t*VectorDir) = D
        //      t = (D -  dot(N, VectorAt)) / dot(N, VectorDir)
        //
        // NOTE: when N is perpendicular to VectorDir, 
        //          dot(N,VectorDir) = 0
        //       line cannot intersect plane
        float nDotDir = Vector3.Dot(p.N, l.VectorDir());
        if (Mathf.Abs(nDotDir) < float.Epsilon) {
            // line almost in the same direction as the plane
            // OR: line almost perpendicular to plane normal
            c = Color.red;  // turn ourself red
            return Vector3.zero;
        }
        
        float t = (p.D - Vector3.Dot(p.N, l.VectorAt())) * (1.0f/nDotDir);
        if ((t < 0f) || (t>l.VectorLength)) {
            // intersection is outside of the line segment
            c = Color.yellow;
        } else {
            c = Color.black;
        }
        // now sub t back into the ALine equation
        return l.VectorAt() + t * l.VectorDir();
        // Note: this intersection is with an infinite-size plane!
    }
}
