using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MirrorLine : MonoBehaviour
{
    public ThePlane APlane = null;
    public ShowVector IncidentRay = null;
    public ShowVector MirroredRay = null;
    public ShowVector ReflectedRay = null;
    // Start is called before the first frame update
    void Start()
    {
        Debug.Assert(APlane != null);
        Debug.Assert(IncidentRay != null);
        Debug.Assert(MirroredRay != null);
        Debug.Assert(ReflectedRay != null);
    }

    // Update is called once per frame
    void Update()
    {
        Color c = Color.black;

        // 1. find the intersection point of incident and the plane
        Vector3 p = LinePlaneIntersection.LinePlaneIntersect(APlane, IncidentRay, out c);
        APlane.gameObject.transform.localPosition = p;
        
        // 2. distance from IndidentRay to p
        float dist = Vector3.Magnitude(IncidentRay.VectorAt() - p); 

        // 3. reflection direction of IncidentRay
        Vector3 r = Vector3.Reflect(IncidentRay.VectorDir(), APlane.N);

        float d1 = dist-IncidentRay.VectorLength;
        // 4. Beginning position of reflected and mirrored rays
        ReflectedRay.SetVectorAt(p + ( d1 * r)); // interested in how far is the end from p
        MirroredRay.SetVectorAt(p - (dist * r));

        // 5. Mirror the IncidentRay.VectorAt() vector
        ReflectedRay.SetVectorDir(r);
        MirroredRay.SetVectorDir(r);

        // Lastly, set the lengths and color
        ReflectedRay.VectorLength = MirroredRay.VectorLength = IncidentRay.VectorLength;
        ReflectedRay.GetComponent<Renderer>().material.color = c;
        MirroredRay.GetComponent<Renderer>().material.color = c;
    }
}
