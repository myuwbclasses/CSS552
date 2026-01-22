using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class VizControl : SceneControlBase
{
    public enum VisToShow
    {
        eShow_V = 1 << 0,
        eShow_L = 1 << 1,
        eShow_N = 1 << 2,
        eShow_H = 1 << 3,
        eShow_R = 1 << 4,
        eShow_NL = 1 << 5,
        eShow_VR = 1 << 6,
        eShow_NH = 1 << 7,
        eShow_VH = 1 << 8,
        eShow_NV = 1 << 9,
        eShow_NHNV= 1 << 10,
        eShow_NHNL = 1 << 11          
    };
    public VisToShow ToShow = VisToShow.eShow_V;

    // Update is called once per frame
    new void Update() // Hide the base Update
    {
        // compute the global render flag
        int flag = (int) ToShow;
        // Debug.Log("flag =" + flag);
        // global shader update
        Shader.SetGlobalInteger("_Flag", flag);
        base.Update();
    }
}
