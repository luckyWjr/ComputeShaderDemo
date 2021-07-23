using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DepthTextureSample : MonoBehaviour
{
    void Start()
    {
        Debug.Log(Camera.main.depthTextureMode);
        Camera.main.depthTextureMode |= DepthTextureMode.Depth;
    }

    void Update()
    {
        
    }
}
