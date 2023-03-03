using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BumpMap : MonoBehaviour
{
    public enum DebugEnum {
        
        eShowNormalAsColor = 0x01,
        eShowTangentAsColor = 0x02,
        eShowNormalMapAsColor = 0x04,
        eUseOrgNormalNoColor = 0x08,
        eUseOrgNormalWithColor = 0x10,
        eUsePerturbedNormalNoColor = 0x20,
        eUsePerturbedNormalWithColor = 0x40,
    };
    public Texture2D MainTex = null;
    public Texture2D NormalMapSource = null;
    
    public float Bumpiness = 1.0f; // typical range between 0 to 2
    public bool RecomputeNormalMap = false;
    public DebugEnum ShowOptions = DebugEnum.eUseOrgNormalWithColor ;  // 0 is off, 1 is show bump as color, 2 is show normal without color map
    public Material BumpMat = null;

    private Texture2D mNormalMap = null;

    // Start is called before the first frame update
    void Start()
    {
        Debug.Assert(MainTex != null);
        Debug.Assert(BumpMat != null);
        
        RecomputeNormalMap = true;
    }

    // Update is called once per frame
    void Update()
    {
        if (RecomputeNormalMap) {
            InitializeNormalMap();
            BumpMat.SetTexture("_MainTex", MainTex);
            // MainTex.Apply();
            BumpMat.SetTexture("_NormalMap", mNormalMap);
            RecomputeNormalMap = false;
        }
        BumpMat.SetInt("_ShowFlag", (int) (ShowOptions));
        BumpMat.SetFloat("_Bumpiness", Bumpiness);
    }

    // Normal map computation support
    int clampTo(int i, int max) { return (i < 0 ? 0 : (i >= max ? max-1 : i)); }

    void InitializeNormalMap() {
        if (mNormalMap == null)
            mNormalMap = new Texture2D(NormalMapSource.width, NormalMapSource.height);
        else
            mNormalMap.Reinitialize(NormalMapSource.width, NormalMapSource.height);
            
        Vector3 n = Vector3.one;
        Color c = Color.black;

        // approximate image height difference based on Sobel Opration (https://en.wikipedia.org/wiki/Sobel_operator)
        // here is an article that explains how normal can be implemented: https://medium.com/@a.j.kruschwitz/how-to-generate-a-normal-map-from-an-image-the-quick-and-dirty-way-36b73a18f1f1 
        for (int x = 0; x < NormalMapSource.width; x++) {
            for (int y = 0; y < NormalMapSource.height; y++) {
                int lx = clampTo(x-1, NormalMapSource.width);   // left of x
                int rx = clampTo(x+1, NormalMapSource.width); // right of x
                int ty = clampTo(y+1, NormalMapSource.height);  // top of y
                int by = clampTo(y-1, NormalMapSource.height); // bottom of y
                float t = NormalMapSource.GetPixel(x, ty).grayscale; // top
                float rt = NormalMapSource.GetPixel(rx, ty).grayscale; //  right top
                float lt = NormalMapSource.GetPixel(lx, ty).grayscale; // left top
                float l = NormalMapSource.GetPixel(lx, y).grayscale;
                float r = NormalMapSource.GetPixel(rx, y).grayscale;
                float b = NormalMapSource.GetPixel(x, by).grayscale;
                float rb = NormalMapSource.GetPixel(rx, by).grayscale;
                float lb = NormalMapSource.GetPixel(lx, by).grayscale;

                n.x = (rt + 2*r + rb) - (lt + 2*l + lb);       // x direction height differentiation
                n.y = (rt + 2*t + lt) - (rb + 2*b + lb);
                n.z = 1.0f;
                n = 0.5f * (n.normalized + Vector3.one);
            
                c.r = n.x;
                c.g = n.y;
                c.b = n.z;
                c.a = 1.0f;

                mNormalMap.SetPixel(x, y, c);
            }
        }
        mNormalMap.Apply();
    }
}
