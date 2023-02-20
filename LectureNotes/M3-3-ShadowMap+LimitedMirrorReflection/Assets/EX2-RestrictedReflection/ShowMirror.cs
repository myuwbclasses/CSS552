using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShowMirror : MonoBehaviour
{
    public MirrorCamControl TheMirror;
    public Material CombineMat;
    // Start is called before the first frame update
    public Color MirrorColor = Color.grey;
    public bool ShowFlipU = true;
    public bool ShowFlipV = false;
    const int kShowFlipU = 0x01;
    const int kShowFlipV = 0x02;
    void Start()
    {
        CombineMat.SetTexture("_MirrorImage", TheMirror.GetMirrorRT());
    }

    // Update is called once per frame
    void Update()
    {
        Shader.SetGlobalColor("_MirrorColor", MirrorColor);
        int flag = 0;
        flag |= (ShowFlipU ? kShowFlipU : 0);
        flag |= (ShowFlipV ? kShowFlipV : 0);
        CombineMat.SetInteger("_ShowFlag", flag);
    }

    void OnRenderImage(RenderTexture src, RenderTexture dst) {
        Graphics.Blit(src, dst, CombineMat);
    }
}