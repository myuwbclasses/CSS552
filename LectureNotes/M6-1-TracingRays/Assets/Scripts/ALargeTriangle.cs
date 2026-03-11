using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class ALargeTriangle : MonoBehaviour {

	// Use this for initialization
    [Range(1f, 20f)] public float mSize = 10f;
    Vector4[] WCVertices;  // limited by datatype of Shader.SetGlobalFloatVector
    Vector4[] WCBary;
    Vector3[] OCVertices;  
	void Start () {
        Mesh theMesh = GetComponent<MeshFilter>().mesh;   // get the mesh component
        theMesh.Clear();    // delete whatever is there!!

        // Vector3[]v = new Vector3[3];     // Allocate new ones! @
        int[] t = new int[3];
        Vector3[] n = new Vector3[3];
        Vector2[] uv = new Vector2[3];
        Color[] c = new Color[3];

        OCVertices = new Vector3[3];
        OCVertices[0] = new Vector3(-0.5f * mSize, 0, -0.5f * mSize);
        OCVertices[1] = new Vector3(0.5f * mSize, 0, 0.5f * mSize);
        OCVertices[2] = new Vector3(0.5f * mSize, 0, -0.5f * mSize);

        n[0] = new Vector3(0, 1, 0);
        n[1] = new Vector3(0, 1, 0);
        n[2] = new Vector3(0, 1, 0);

        uv[0] = new Vector2(0, 0);
        uv[1] = new Vector2(1, 1);
        uv[2] = new Vector2(1, 0);
        
        t[0] = 0;   // t array is always multiples of 3
        t[1] = 1;   //  WATCH for the default culling!! CCW by default is culled!
        t[2] = 2;
        
        c[0] = Color.red;
        c[1] = Color.green; 
        c[2] = Color.blue;

        theMesh.vertices = OCVertices; //  new Vector3[3];
        theMesh.triangles = t; //  new int[3];
        theMesh.normals = n;
        theMesh.uv = uv;
        theMesh.uv2 = uv;
        theMesh.colors = c;

        WCVertices = new Vector4[3];
        WCBary = new Vector4[3];
        /*
            NEVER do this:
                mesh.vertices = new Vector3[3];
                mesh.vertices[0] = new Vector3(0, 1, 0);
            
            The above DOES NOT WORK!! YOU MUST FIRST allocate and set the arrays BEFORE
            assigning to mesh.WHATEVER

            I believe, during the assignment, mesh initialize stuff!
          */
    }

    // Update is called once per frame
    void Update () {
        // Update the vertices with WC positions
        Vector3[] p = new Vector3[3];
        for (int i = 0; i < 3; i++)
        { 
            p[i] = transform.TransformPoint(OCVertices[i]);
            WCVertices[i] = new Vector4(p[i].x, p[i].y, p[i].z, 1.0f);
        }
        Vector3 n = Vector3.Cross((p[1]-p[0]), (p[2]-p[0]));
        float a = 1.0f/n.magnitude;
        n *= a;
        float D = Vector3.Dot(n, p[0]);

        Shader.SetGlobalVectorArray("_TheTriangle", WCVertices);
        Shader.SetGlobalFloat("_TriA2Inv", a);
        Shader.SetGlobalVector("_TriNormal", n);
        Shader.SetGlobalFloat("_TriD", D);

        // Debug.Log("Triangle N="+ n + " D=" + D + " a=" + a);
        // Debug.Log("Triangle vetices:" + WCVertices[0] + " " + WCVertices[1] + " " + WCVertices[2]);

	}
}
