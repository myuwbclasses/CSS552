using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SelectReplacement : MonoBehaviour
{
    public enum ShaderOption {
        NoShaderReplacement,
        ConstantColorShader,
        MySimpleDefault,
        BlueUnity,
        RedUnity,
        
    };

    public ShaderOption UseShader = ShaderOption.NoShaderReplacement;
    
    public Shader ConstColorShader = null;
    public Shader MySimpleDefault = null;
    public Shader BlueUnityWithTag = null;
    public Shader RedUnityWithTag = null;

    // Start is called before the first frame update
    void Start()
    {
        Debug.Assert(ConstColorShader != null);
        Debug.Assert(MySimpleDefault != null);
        Debug.Assert(BlueUnityWithTag != null);
        Debug.Assert(RedUnityWithTag != null);
    }

    // Update is called once per frame
    void Update()
    {
        switch (UseShader) {
            case ShaderOption.NoShaderReplacement:
                GetComponent<Camera>().ResetReplacementShader();
                break;
            case ShaderOption.ConstantColorShader:
                GetComponent<Camera>().SetReplacementShader(ConstColorShader, "ConstantColor");
                    // 1. Goes through all objects in the scene, find all shaders with "ConstantColor" Tag
                    // 2. match the values of the tag with the subshaders in ConstantColorShader
                    //             ConstantColorShader: has two values defined: red and blue
                    // 3. renders GameObjects with the corresponding subShader in ConstColorShader
                break;
            case ShaderOption.MySimpleDefault:
                GetComponent<Camera>().SetReplacementShader(MySimpleDefault, "ConstantColor");
                    // this only has "blue"
                break;
            case ShaderOption.BlueUnity:
                GetComponent<Camera>().SetReplacementShader(BlueUnityWithTag, "ConstantColor");
                    // this only has "blue"
                break;
            case ShaderOption.RedUnity:
                GetComponent<Camera>().SetReplacementShader(RedUnityWithTag, "ConstantColor");
                    // this only has "blue"
                break;
        } 
    }
}
