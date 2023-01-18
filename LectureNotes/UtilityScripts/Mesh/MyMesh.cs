using UnityEngine;
using System.Collections;

// Read about mesh: https://docs.unity3d.com/ScriptReference/Mesh.html
//

public partial class MyMesh : MonoBehaviour {
    public bool RefreshMesh = false;
    public int NewResolution = 30;

    private float kInitSize = 10f;

      
    // Use this for initialization
    protected void Start() {
        // transform.localScale = new Vector3(kInitSize, kInitSize, kInitSize);

        NewResolution = mResolution;

        BuildNewMesh();
    }

    // Update is called once per frame
    protected void Update() {
        if (!RefreshMesh)
            return;
        
        RefreshMesh = false;
        SetResolution(NewResolution);
        
        Mesh m = GetComponent<MeshFilter>().mesh;
        Vector3[] v = m.vertices;
        Vector3[] n = m.normals;
        Vector2[] uv = m.uv;
        int[] t = m.triangles;

        // OK, this is stupid and very inefficient, but ... for now
        // UpdateTextureTransform(uv);

        m.Clear();
        m.vertices = v;
        m.normals = n;
        m.uv = uv;
        m.triangles = t;
    }

    // Support for creation
    private int mResolution = 20;
    // Resolution x Resolution number of vertices
    // R-1 x R-1 x 2 number of triangles

    protected int mNumVertices;
    protected int mNumTriangles;

    private const int kLowerTriangleFlag = 0;
    private const int kUpperTriangleFlag = 1;

    class TriangleIndices
    {
        public int[,] v;  // vertices, 0 is for lower, 1 is for upper
        public TriangleIndices()
        {
            v = new int[2, 3] { { 0, 0, 0 }, { 0, 0, 0 } };
        }
    };

    public void SetResolution(int n)
    {
        if ((n < 2)) //  || (n == mResolution))
            return; // ignore

        mResolution = n;
        BuildNewMesh();

    }
    // Assume Resolution is a good number (>= 2)
    bool BuildNewMesh()
    {
        Mesh mesh = GetComponent<MeshFilter>().mesh;
        mesh.Clear();

        int nv = mResolution * mResolution;
        if (nv == mesh.vertices.Length)  // Assume we are good.
            return false;

        // other wise ...        
        mNumTriangles = (mResolution - 1) * (mResolution - 1) * 2 * 3;  // these are the vertices of the triangles
        mNumVertices = nv;
        Debug.Log("Mesh init: NumTriangles:" + mNumTriangles + " NumVertices:" + mNumVertices);

        // set the vertices (x, 0, z)
        Vector3[] v = new Vector3[mNumVertices];
        Vector3[] n = new Vector3[mNumVertices];
        Vector2[] uv = new Vector2[mNumVertices];
        ComputeUV(uv);
        ComputeVertex(v, n);


        // set the triangles:
        //    r/c = row/column , 0 th n-1
        //    each location, has u/l upper/lower triangle
        int[] t = new int[mNumTriangles];
        TriangleIndices ti = new TriangleIndices();
        for (int y = 0; y < (mResolution - 1); y++)
            for (int x = 0; x < (mResolution - 1); x++) { 

                GetTriangleIndices(x, y, ref ti);
                int index = PosToTriangleIndex(x, y, kLowerTriangleFlag);

                for (int i = 0; i < 3; i++)
                {
                    t[index + i] = ti.v[0, i]; // lower triangle

                    t[index + 3 + i] = ti.v[1, i]; // upper triangle
                }
            }

        // create a new mesh component
        mesh.vertices = v;
        mesh.triangles = t;
        mesh.normals = n;
        mesh.uv = uv;

        return true;

        /*
            NEVER do this:
                mesh.colors = new Color[3];
                mesh.colors[0] = new Color(0, 1, 0);
            
            The above DOES NOT WORK!! YOU MUST FIRST allocate and set the arrays BEFORE
            assigning to mesh.WHATEVER

            I believe, during the assignment, mesh initialize stuff!
          */
    }

    // in all of the following:
    // row      --> y-value (i-values)
    // column   --> x-value (j-values)

    // (x, y): column/row index of a vertex
    // returns the 1D index of Vertex[]
    protected int PosToVertexIndex(int x, int y)
    {
        return x + (y * mResolution);
    }

    // (x, y): column/row of the lower-left corner
    // ul - 0 for lower and 1 for upper
    // returns the index of the triangle-array, 
    //      the design is such that:
    //      Triangle-Low: index   to index+2
    //      Triangle-hi : index+3 to index+5
    // 
    protected int PosToTriangleIndex(int x, int y, int ul)
    {
        return ((2 * (x + (y * (mResolution - 1)))) + ul) * 3;
    }

    // (x,y): column/row of lower left corner
    // returns the triangle[] indices for both lower [0] and upper [1]
    void GetTriangleIndices(int x, int y, ref TriangleIndices ti)
    {
        int yn = y * mResolution;
        int y1n = (y + 1) * mResolution;

        ti.v[0, 0] = yn + x;      // Lower triangle
        ti.v[0, 1] = y1n + x + 1;
        ti.v[0, 2] = yn + x + 1;

        ti.v[1, 0] = yn + x;      // upper triangle
        ti.v[1, 1] = y1n + x;
        ti.v[1, 2] = y1n + x + 1;
    }

    virtual protected void ComputeVertex(Vector3[] v, Vector3[] n)
    {
        float delta = 2f / (float)(mResolution - 1);
        for (int y = 0; y < mResolution; y++)
        {
            float yVal = -1f + y * delta;
            for (int x = 0; x < mResolution; x++)
            {
                float xVal = -1f + (x * delta);
                int index = PosToVertexIndex(x, y);
                v[index] = new Vector3(xVal, 0, yVal);
                n[index] = new Vector3(0, 1f, 0);
            }
        }
    }

    // Texture Coordinate 
    void ComputeUV(Vector2[] uv)
    {
        float delta = 2f / (float)(mResolution - 1);
        for (int y = 0; y < mResolution; y++)
        {
            for (int x = 0; x < mResolution; x++)
            {
                int index = PosToVertexIndex(x, y);
                uv[index] = new Vector2(x * delta * 0.5f, y * delta * 0.5f);
            }
        }
    }
}
