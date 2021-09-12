using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class CommandBufferController : MonoBehaviour
{
    public Mesh sampleMesh;
    public Material sampleMatial;

    void Start()
    {
        Light light = GameObject.Find("Directional Light").GetComponent<Light>();

        CommandBuffer cb = new CommandBuffer();
        cb.EnableShaderKeyword("LIGHTPROBE_SH");
        cb.EnableShaderKeyword("SHADOWS_SCREEN");
        MaterialPropertyBlock mb = new MaterialPropertyBlock();
        mb.SetTexture("_ShadowMapTexture", Shader.GetGlobalTexture("_ShadowMapTexture"));
        cb.DrawMesh(sampleMesh, Matrix4x4.TRS(Vector3.zero, Quaternion.identity, Vector3.one), sampleMatial, 0, 0, mb);
        Camera.main.AddCommandBuffer(CameraEvent.AfterForwardOpaque, cb);

        CommandBuffer cb1 = new CommandBuffer();
        cb1.DrawMesh(sampleMesh, Matrix4x4.TRS(Vector3.zero, Quaternion.identity, Vector3.one), sampleMatial, 0, sampleMatial.FindPass("ShadowCaster"));
        Camera.main.AddCommandBuffer(CameraEvent.AfterDepthTexture, cb1);

        CommandBuffer cb2 = new CommandBuffer();
        cb2.DrawMesh(sampleMesh, Matrix4x4.TRS(Vector3.zero, Quaternion.identity, Vector3.one), sampleMatial, 0, sampleMatial.FindPass("ShadowCaster"));
        light.AddCommandBuffer(LightEvent.AfterShadowMapPass, cb2);
    }
}
