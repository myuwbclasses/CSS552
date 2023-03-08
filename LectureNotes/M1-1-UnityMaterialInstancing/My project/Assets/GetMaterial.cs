using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GetMaterial : MonoBehaviour
{
    // Start is called before the first frame update
    Material myMat = null;
    void Start()
    {
        myMat = GetComponent<Renderer>().material;
    }

    // Update is called once per frame
    void Update()
    {
    }
}
