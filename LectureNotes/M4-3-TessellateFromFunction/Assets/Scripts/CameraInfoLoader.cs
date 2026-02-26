using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraInfoLoader : MonoBehaviour
{
    public Material TessMat;
    void Update() {
        TessMat.SetVector("_CameraPos", Camera.main.transform.position);
        TessMat.SetVector("_CameraDir", Camera.main.transform.forward);
        TessMat.SetFloat("_ScreenWidth", Camera.main.pixelWidth);
        TessMat.SetFloat("_ScreenHeight", Camera.main.pixelHeight); 
        TessMat.SetFloat("_FovY", Camera.main.fieldOfView);
    }
}
