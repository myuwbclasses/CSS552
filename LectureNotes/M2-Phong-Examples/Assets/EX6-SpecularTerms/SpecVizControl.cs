using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class SpecVizControl : SceneControlBase
{
    public enum SpecToShow
    {
        eShow_ClassicPhong = 1 << 0,
        eShow_BlinnPhong = 1 << 1,
        eShow_NormalizedBlinnPhong = 1 << 2,
        eShow_NormalD = 1 << 3,
        eShow_Geom_DDX = 1 << 4,
        eShow_Fersnel = 1 << 5,
        eShow_CT_NBlinnPhong = 1 << 6,
        eShow_CT_Normal_D = 1 << 7
    
    };
    public SpecToShow sToShow = SpecToShow.eShow_ClassicPhong;
    
    // Start is called before the first frame update
    void Start()
    {
        Debug.Assert(LightPosition != null);
    }

    // Update is called once per frame
    new void Update()  // Hide the base.Update
    {
        // compute the global render flag
        int flag = (int) sToShow;
        // Debug.Log("flag =" + flag);
        // global shader update
        Shader.SetGlobalInteger("_EX6_ShaderMode", flag);
        base.Update(); // For Camera and Light Pos
    }
}
