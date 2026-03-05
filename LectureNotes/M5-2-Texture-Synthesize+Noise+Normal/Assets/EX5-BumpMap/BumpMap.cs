using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BumpMap : MonoBehaviour
{
    public enum DebugEnum {
        
        eShowNormalAsColor = 0x01 << 0,
        eShowNdotL = 0x01 << 1,
        eShowUnshadedColor = 0x01 << 2,
        eShowShadedColor = 0x01 << 3,
    };
    const int kUseBumppedNormal = 0x01 << 10;
    
    public bool UseBumpNormal = true;
    [Range(-0.2f, 0.2f)]  public float BumpinessU = 0.1f; // 
    [Range(0.05f, 2f)] public float DuDistance = 0.5f; // % of UV space: 1 is 0.01 in UV unit
    [Range(-0.2f, 0.2f)]    public float BumpinessV = 0.5f; 
    [Range(0.05f, 2f)] public float DvDistance = 1f; // % of UV space: 1 is 0.01 in UV unit
    public DebugEnum ShowOptions = DebugEnum.eShowShadedColor;

    public Material GlobalBumpMaterial;

    // Start is called before the first frame update
    void Start()
    {
        Debug.Assert(GlobalBumpMaterial != null);
    }

    // Update is called once per frame
    void Update()
    {
        // controls all of the materials (Bump and Normal)
        int f = (int) ShowOptions;
        f |= UseBumpNormal ? kUseBumppedNormal : 0;

        GlobalBumpMaterial.SetInt("_ShowFlag", f);
        GlobalBumpMaterial.SetFloat("_BumpinessU", BumpinessU);
        GlobalBumpMaterial.SetFloat("_BumpinessV", BumpinessV);
        GlobalBumpMaterial.SetFloat("_DuDistance", DuDistance);
        GlobalBumpMaterial.SetFloat("_DvDistance", DvDistance);
    }
}
