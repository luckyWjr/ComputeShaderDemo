using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DrawParticle : MonoBehaviour
{
    public ComputeShader computeShader;
    public Material material;

    ComputeBuffer mParticleDataBuffer;
    const int mParticleCount = 20000;
    int kernelId;

    struct ParticleData {
        public Vector3 pos;
        public Color color;
    }

    void Start() {
        //struct中一共7个float，size=28
        mParticleDataBuffer = new ComputeBuffer(mParticleCount, 28);
        ParticleData[] particleDatas = new ParticleData[mParticleCount];
        mParticleDataBuffer.SetData(particleDatas);
        kernelId = computeShader.FindKernel("UpdateParticle");
    }

    void Update() {
        computeShader.SetBuffer(kernelId, "ParticleBuffer", mParticleDataBuffer);
        computeShader.SetFloat("Time", Time.time);
        computeShader.Dispatch(kernelId, mParticleCount / 1000, 1, 1);
        material.SetBuffer("_particleDataBuffer", mParticleDataBuffer);
    }

    void OnRenderObject() {
        material.SetPass(0);
        Graphics.DrawProceduralNow(MeshTopology.Points, mParticleCount);
    }

    void OnDestroy() {
        mParticleDataBuffer.Release();
        mParticleDataBuffer.Dispose();
    }
}
