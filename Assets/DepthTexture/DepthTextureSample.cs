using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class DepthTextureSample : MonoBehaviour {
    public Shader showDepthTextureShader;

    Material m_showDepthTextureMaterialCache;
    Material m_showDepthTextureMaterial{
        get {
            if(m_showDepthTextureMaterialCache == null)
                m_showDepthTextureMaterialCache = new Material(showDepthTextureShader);
            return m_showDepthTextureMaterialCache;
        }
    }

    void Start()
    {
        Debug.Log(Camera.main.depthTextureMode);
        Camera.main.depthTextureMode |= DepthTextureMode.Depth;
    }

    void Update()
    {
        
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination) {
        if(showDepthTextureShader != null)
            Graphics.Blit(source, destination, m_showDepthTextureMaterial);
        else
            Graphics.Blit(source, destination);
    }
}
