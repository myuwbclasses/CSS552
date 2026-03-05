using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NormalMap : MonoBehaviour
{
    public enum DebugEnum {
        eShowNormalAsColor = 0x01 << 0,
        eShowNdotL = 0x01 << 1,
        eShowUnshadedColor = 0x01 << 2,
        eShowShadedColor = 0x01 << 3,
    };
    const int kUseNormalMap = 0x01 << 10;
    const int kUseTangentSpaceNormal = 0x01 << 11;
    
    public bool UseNormalMap = true;
    public bool UseTangentSpaceNormal = true;

    [Range(-2f, 2f)]  public float Bumpiness = 1f; // 

    public DebugEnum ShowOptions = DebugEnum.eShowShadedColor;

    public Material GlobalNormalMapMaterial;

    // Start is called before the first frame update
    void Start()
    {
        Debug.Assert(GlobalNormalMapMaterial != null);
    }

    // Update is called once per frame
    void Update()
    {
        // controls all of the materials (Bump and Normal)
        int f = (int) ShowOptions;
        f |= UseNormalMap ? kUseNormalMap : 0;
        f |= UseTangentSpaceNormal ? kUseTangentSpaceNormal : 0;

        GlobalNormalMapMaterial.SetInt("_ShowFlag", f);
        GlobalNormalMapMaterial.SetFloat("_Bumpiness", Bumpiness);
    }
}
