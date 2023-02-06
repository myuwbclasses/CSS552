using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BlurProcessing : MonoBehaviour
{
    public enum PostProcessShow {
        ShowOriginal = 0,
        FindBrightPixels = 1, 
        BlurPixels = 2,
        BlurBrightPixels = 3,
        BlurOnlyBrightAndCombine = 4
    };
    public PostProcessShow PostToShow = PostProcessShow.ShowOriginal;

    public Material FindBrightPixelMat = null;  // from EX3-PostProcessing
    public Color BrightCutOff = Color.grey;
    // Start is called before the first frame update

    // for blurring
    public Material BlurPixelMat = null;

    public Material CombineMat = null;
    public float Weight = 0.5f; // How much of blur to use

    RenderTexture Bright_RT, Blurred_RT;

    void Start()
    {
        Debug.Assert(FindBrightPixelMat != null);
        Debug.Assert(BlurPixelMat != null);

        #region // for blurring support
        float invW = 1.0f/(float)Camera.main.pixelWidth;
        float invH = 1.0f/(float)Camera.main.pixelHeight;

        BlurPixelMat.SetFloat("_invWidth", invW);
        BlurPixelMat.SetFloat("_invHeight", invH);
        #endregion

        Bright_RT = null; 
        Blurred_RT = null;
    }

    // Update is called once per frame
    void Update()
    {
        FindBrightPixelMat.SetColor("_BrightCutoff", BrightCutOff);

        CombineMat.SetFloat("_blendWeight", Weight);
    }

    void OnRenderImage(RenderTexture src, RenderTexture dst) {
        if (Bright_RT == null) {
            Bright_RT = new RenderTexture(src.descriptor);
            Blurred_RT = new RenderTexture(src.descriptor);
        }

        switch (PostToShow) {
            case PostProcessShow.ShowOriginal:
                Graphics.Blit(src, dst);
                break;
            
            case PostProcessShow.FindBrightPixels:
                Graphics.Blit(src, dst, FindBrightPixelMat);
                break;
            
            case PostProcessShow.BlurPixels:
                Graphics.Blit(src, dst, BlurPixelMat);
                break;
            
            case PostProcessShow.BlurBrightPixels:
                Graphics.Blit(src, Bright_RT, FindBrightPixelMat);
                Graphics.Blit(Bright_RT, dst, BlurPixelMat);
                break;
            case PostProcessShow.BlurOnlyBrightAndCombine:
                Graphics.Blit(src, Bright_RT, FindBrightPixelMat);
                Graphics.Blit(Bright_RT, Blurred_RT, BlurPixelMat);
                CombineMat.SetTexture("_AnotherImage", Blurred_RT);
                Graphics.Blit(src, dst, CombineMat);
                break;
        }
    }
}