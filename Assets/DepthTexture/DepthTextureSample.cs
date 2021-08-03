using System.Collections;
using System.Collections.Generic;
using UnityEngine;

//[ExecuteInEditMode]
public class DepthTextureSample : MonoBehaviour {
    //public Shader showDepthTextureShader;

    //Material m_showDepthTextureMaterialCache;
    //Material m_showDepthTextureMaterial{
    //    get {
    //        if(m_showDepthTextureMaterialCache == null)
    //            m_showDepthTextureMaterialCache = new Material(showDepthTextureShader);
    //        return m_showDepthTextureMaterialCache;
    //    }
    //}
    public Material mat;

    void Start()
    {
        Debug.Log(Camera.main.depthTextureMode);
        Camera.main.depthTextureMode |= DepthTextureMode.Depth;

    }


    void OnRenderImage(RenderTexture source, RenderTexture destination) {
        if(mat != null) {
            Graphics.Blit(source, destination, mat);
        }
        else
            Graphics.Blit(source, destination);
    }
}
