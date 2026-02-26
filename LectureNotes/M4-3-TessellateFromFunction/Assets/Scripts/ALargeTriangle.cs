using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ALargeTriangle : MonoBehaviour {

	// Use this for initialization
    [Range(1f, 20f)] public float mSize = 10f;
	void Start () {
        Mesh theMesh = GetComponent<MeshFilter>().mesh;   // get the mesh component
        theMesh.Clear();    // delete whatever is there!!

        Vector3[]v = new Vector3[3];     // Allocate new ones! @
        int[] t = new int[3];
        Vector3[] n = new Vector3[3];
        Vector2[] uv = new Vector2[3];
        Color[] c = new Color[3];


        v[0] = new Vector3(-0.5f * mSize, 0, -0.5f * mSize);
        v[1] = new Vector3(0.5f * mSize, 0, 0.5f * mSize);
        v[2] = new Vector3(0.5f * mSize, 0, -0.5f * mSize);

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

        theMesh.vertices = v; //  new Vector3[3];
        theMesh.triangles = t; //  new int[3];
        theMesh.normals = n;
        theMesh.uv = uv;
        theMesh.uv2 = uv;
        theMesh.colors = c;

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
		
	}
}
