using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MaterialControl : MonoBehaviour
{
    // must agree with Structs.cginc constants
    // OC flags
    const uint OC_SHOW          = 0x01;
    const uint OC_ANIMATED      = 0x02;
    const uint OC_USE_VPOINT    = 0x04;

// WC Flags
    const uint WC_SHOW          = 0x10;
    const uint WC_ANIMATED      = 0x20;
    const uint WC_USE_OCVPOINT  = 0x40;

// EC Flags
    const uint EC_SHOW          = 0x100;
    const uint EC_ANIMATED      = 0x200;
    const uint EC_USE_OCVPOINT  = 0x400;
    const uint EC_USE_WCVPOINT  = 0x080;
    const uint EC_ONLY_Z        = 0x800;
    const uint PC_SHOW          = 0x1000;
    const uint PC_ANIMATED      = 0x2000;
    const uint PC_USE_OCVPOINT  = 0x4000;
    const uint PC_USE_WCVPOINT  = 0x8000;

    const uint SHOW_ORIGINAL = 0x100000;

    public Material mMat = null; // 
    public bool ShowOriginal = true; // to see OC vanish, need to hide original

    // Object Coordinate (OC) Space
    public float OC_Weight = 1f;
    public bool OC_Show = false;
    public bool OC_Animated = false;
    public bool OC_UseVPoint = false;
    public Vector3 OC_VPoint = Vector3.zero;
    
    
    // World Coordinate (WC) Space
    public float WC_Weight = 1f;
    public bool WC_Show = false;
    public bool WC_Animated = false;
    public float WC_Rate = 1f;
    public bool WC_UseOCVPoint = false;
    public Transform WC_VPoint = null;        
    
    
    // Eye Coordinate (EC) space
    public float EC_Weight = 1f;
    public bool EC_Show = false;
    public bool EC_Animated = false;
    public bool EC_UseOCVPoint = false;
    public bool EC_UseWCVPoint = false;
    public bool EC_OnlyZ = false;
    // public Camera EC_Near = null; // for keeping track of near plane  

    // Perspective Coordinate (PC) Space
    public float PC_Weight = 1f;
    public bool PC_Show = false;
    public bool PC_Animated = false;
    public Vector3 PC_VPoint = Vector3.zero;
    public bool PC_UseOCVPoint = false;
    public bool PC_UseWCVPoint = false;
    
    public Color ObjColor = Color.gray;

    void Start() {
        Debug.Assert(WC_VPoint != null);

        if (mMat == null) {  // not set in the UI
            mMat = GetComponent<Renderer>().material;  
            // this will create a separate instance of material for this game object
        }
    }

    void Update() {
        // Control flag update
        mMat.SetInteger("_UserControl", (int) UpdateControlFlag());

        // OC
        mMat.SetFloat("_OCWeight", OC_Weight);
        mMat.SetVector("_OCVPoint", OC_VPoint);

        // World space control
        mMat.SetFloat("_WCWeight", WC_Weight);
        mMat.SetFloat("_WCRate", WC_Rate);
        mMat.SetVector("_WCVPoint", WC_VPoint.localPosition);

        // Eye Coordinate control
        mMat.SetFloat("_ECNear", Camera.main.nearClipPlane);
        mMat.SetFloat("_ECWeight", EC_Weight);

        // Projected Coordinate control
        mMat.SetFloat("_PCWeight", PC_Weight);
        mMat.SetVector("_PCVPoint", PC_VPoint);
    
        mMat.SetColor("_Color", ObjColor);
    }

    uint UpdateControlFlag() {
        uint f = 0x0;
        // You wil have to compute this flag
        return f;
    }
};