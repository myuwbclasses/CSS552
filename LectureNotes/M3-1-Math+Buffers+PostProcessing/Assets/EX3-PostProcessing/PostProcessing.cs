using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PostProcessing : MonoBehaviour
{
    public enum PostProcessShow {
        ShowOriginal = 0,
        FindBrightPixels = 1
    };
    public PostProcessShow PostToShow = PostProcessShow.ShowOriginal;

    public Material FindBrightPixelMat = null;
    public Color BrightCutOff = Color.grey;
    // Start is called before the first frame update
    void Start()
    {
        Debug.Assert(FindBrightPixelMat != null);
    }

    // Update is called once per frame
    void Update()
    {
        FindBrightPixelMat.SetColor("_BrightCutoff", BrightCutOff);
    }

    void OnRenderImage(RenderTexture src, RenderTexture dst) {
        switch (PostToShow) {
            case PostProcessShow.ShowOriginal:
                Graphics.Blit(src, dst);
                break;
            
            case PostProcessShow.FindBrightPixels:
                Graphics.Blit(src, dst, FindBrightPixelMat);
                break;
        }
    }
}