using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EffectCamControl : MonoBehaviour
{
    public Camera EffectCam;
    
    public bool UpdateCam = false;
    public bool SeePlaneInRendering = false;

    public Transform ThePlane = null;


    // Start is called before the first frame update
    void Start()
    {
        Debug.Assert(EffectCam != null);
        Debug.Assert(ThePlane != null);
    }

    // Update is called once per frame
    void Update()
    {
        if (UpdateCam) {
            
            // 1. set effect cam to follow the main cam
            EffectCam.transform.localPosition = transform.localPosition;
            EffectCam.transform.localRotation = transform.localRotation;        

            ThePlane.gameObject.SetActive(SeePlaneInRendering); // don't render this, otherwise, it will be like we be seeing ourself in a mirror?
            // now render with effectCam
            EffectCam.Render();
            ThePlane.gameObject.SetActive(true);  // always show plane for MainCamera
        }
    }
}
