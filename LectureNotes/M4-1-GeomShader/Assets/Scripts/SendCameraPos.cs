using UnityEngine;

public class SendCameraPos : MonoBehaviour
{
    public Material TargetMat = null;
    void Start()
    {
        Debug.Assert(TargetMat != null);
    }   
    void Update()
    {
        TargetMat.SetVector("_MainCameraPos", transform.localPosition);
    }
}