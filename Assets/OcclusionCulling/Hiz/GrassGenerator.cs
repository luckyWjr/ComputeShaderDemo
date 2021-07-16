using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GrassGenerator : MonoBehaviour
{
    public Mesh grassMesh;
    public Material grassMaterial;
    public Vector2 grassDensity = new Vector2(2, 2);
    uint m_grassCount;

    ComputeBuffer argsBuffer;
    uint[] args = new uint[5] { 0, 0, 0, 0, 0 };
    uint[] cullResultCountArray = new uint[1] { 0 };

    ComputeBuffer cullResult;

    void Start()
    {
        m_grassCount = (uint)grassDensity.x * (uint)grassDensity.y;
        Debug.Log("m_grassCount:" + m_grassCount);
        argsBuffer = new ComputeBuffer(1, args.Length * sizeof(uint), ComputeBufferType.IndirectArguments);
        cullResult = new ComputeBuffer((int)m_grassCount, sizeof(float) * 16);
        InitGrassPosition();
    }

    void Update()
    {
        grassMaterial.SetBuffer("positionBuffer", cullResult);
        Graphics.DrawMeshInstancedIndirect(grassMesh, 0, grassMaterial, new Bounds(Vector3.zero, new Vector3(100.0f, 100.0f, 100.0f)), argsBuffer);
    }

    void InitGrassPosition() {
        float xStep = 80 / grassDensity.x;
        float zStep = 80 / grassDensity.y;
        List<Matrix4x4> grassMatrixs = new List<Matrix4x4>();
        for(int i = 0; i < grassDensity.x; i++) {
            for(int j = 0; j < grassDensity.y; j++) {
                Vector2 xz = new Vector2(-40 + xStep * i, -40 + zStep * j);
                Vector3 position = new Vector3(xz.x, GetGroundHeight(xz), xz.y);
                float size = Random.Range(0.5f, 1.5f);
                grassMatrixs.Add(Matrix4x4.TRS(position, Quaternion.identity, new Vector3(size, size, size)));
            }
        }
        cullResult.SetData(grassMatrixs);

        if(grassMesh != null) {
            args[0] = grassMesh.GetIndexCount(0);
            args[1] = m_grassCount;
            args[2] = grassMesh.GetIndexStart(0);
            args[3] = grassMesh.GetBaseVertex(0);
        }
        else {
            args[0] = args[1] = args[2] = args[3] = 0;
        }
        argsBuffer.SetData(args);
    }

    float GetGroundHeight(Vector2 xz) {
        RaycastHit hit;
        if(Physics.Raycast(new Vector3(xz.x, 10, xz.y), Vector3.down, out hit, 20)) {
            return 10 - hit.distance;
        }
        return 0;
    }

    void OnDisable() {
        cullResult?.Release();
        cullResult = null;

        argsBuffer?.Release();
        argsBuffer = null;
    }
}
