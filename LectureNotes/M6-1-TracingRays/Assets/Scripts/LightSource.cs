using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LightSource : MonoBehaviour
{
    public enum LightStateEnum {
        // eLightOff = 0,
        eLightDirectional = 1,
        eLightPoint = 2,
        eLightSpot = 3
    };

    public bool LightIsOn = true;
    public LightStateEnum LightState = LightStateEnum.eLightDirectional;
    public Color LightColor = Color.white;
    public float Intensity = 2.0f;
    public float Near = 55.0f;
    public float Far = 80.0f;
    public float SpotInner = 25.0f; // angle 
    public float SpotOuter = 45.0f; 
    public float SpotDropOff = 1.0f;
    
    public bool ShowDebug = false;

    GameObject mNearSph, mFarSph, mInner, mOuter;
    LineSegment mDirection;

    const float kIndicationThickness = 0.2f;
    const float kDirectionWidth = 0.25f;
    
    void Start()
    {
        mNearSph = GameObject.CreatePrimitive(PrimitiveType.Sphere);
        mFarSph =  GameObject.CreatePrimitive(PrimitiveType.Sphere);
        mNearSph.GetComponent<MeshRenderer>().material = Resources.Load<Material>("Mat/Default_Transparent");
        mFarSph.GetComponent<MeshRenderer>().material = Resources.Load<Material>("Mat/Default_Transparent");
        mNearSph.name = "Near";
        mFarSph.name = "Far";

        GameObject g = GameObject.CreatePrimitive(PrimitiveType.Cylinder);
        g.name = "Direction";
        mDirection = g.AddComponent<LineSegment>();
        mDirection.SetWidth(kDirectionWidth);

        mInner = GameObject.CreatePrimitive(PrimitiveType.Sphere);
        mOuter = GameObject.CreatePrimitive(PrimitiveType.Sphere);
        mInner.GetComponent<MeshRenderer>().material = Resources.Load<Material>("Mat/Default_Transparent");
        mInner.GetComponent<MeshRenderer>().material.color = Color.red;
        mOuter.GetComponent<MeshRenderer>().material = Resources.Load<Material>("Mat/Default_Transparent");
        mOuter.GetComponent<MeshRenderer>().material.color = Color.red;
        mInner.name = "Inner";
        mOuter.name = "Outer";

        mNearSph.transform.SetParent(transform, false);
        mFarSph.transform.SetParent(transform, false);
        g.transform.SetParent(transform, false);
        mInner.transform.SetParent(transform, false);
        mOuter.transform.SetParent(transform, false);
    }

    // Update is called once per frame
    void Update()
    {
        mNearSph.SetActive(LightIsOn && false);
        mFarSph.SetActive(LightIsOn && false);
        mInner.SetActive(LightIsOn && false);
        mOuter.SetActive(LightIsOn && false);
        mDirection.gameObject.SetActive(LightIsOn && false);

        if (LightIsOn && ShowDebug) {

            if ((LightState == LightStateEnum.eLightPoint) || (LightState == LightStateEnum.eLightSpot)) {
                mNearSph.SetActive(true);
                mFarSph.SetActive(true);

                // mNearSph.transform.localPosition = transform.localPosition;
                float r = 2.0f * Near;
                mNearSph.transform.localScale = new Vector3(r, r, r);

                // mFarSph.transform.localPosition = transform.localPosition;
                r = 2.0f * Far; 
                mFarSph.transform.localScale = new Vector3(r, r, r);
            }

            if ((LightState == LightStateEnum.eLightDirectional) || (LightState == LightStateEnum.eLightSpot)) {
                mDirection.gameObject.SetActive(true);
                // mDirection.SetEndPoints(transform.localPosition, transform.localPosition - Far * transform.up);
                mDirection.SetEndPoints(Vector3.zero, -Far * Vector3.up);
            }

            if (LightState == LightStateEnum.eLightSpot) {
                mInner.SetActive(true);
                mOuter.SetActive(true);
                float sizeAtNear = Near * Mathf.Tan(SpotInner*Mathf.Deg2Rad);
                // mInner.transform.localPosition = transform.localPosition - Near * 0.5f * transform.up;
                mInner.transform.localPosition = -Near * Vector3.up;
                mInner.transform.localScale = new Vector3(sizeAtNear, kIndicationThickness, sizeAtNear);

                float sizeAtFar = Far * Mathf.Tan(SpotOuter*Mathf.Deg2Rad);
                // mOuter.transform.localPosition = transform.localPosition - Far * 0.5f * transform.up;
                mOuter.transform.localPosition = -Far * Vector3.up;
                mOuter.transform.localScale = new Vector3(sizeAtFar, kIndicationThickness, sizeAtFar);
            }

        }
    }
}