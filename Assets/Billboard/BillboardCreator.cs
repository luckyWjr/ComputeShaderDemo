using UnityEngine;

public class BillboardCreator : MonoBehaviour
{
    [SerializeField] Transform[] m_pointList;
    [SerializeField] Texture2D[] m_textures;
    [SerializeField] Material m_material;

    Mesh m_mesh;

    void Start()
    {
        // 设置texture2d array
        int textureArrayLength = m_textures.Length;
        Texture2DArray textureArray = new Texture2DArray(512, 512, textureArrayLength, m_textures[0].format, false);
        for (int i = 0; i < textureArrayLength; ++i)
            Graphics.CopyTexture(m_textures[i], 0, 0, textureArray, i, 0);
        textureArray.Apply();
        m_material.SetTexture("_Textures", textureArray);
        m_material.SetInt("_TextureCount", textureArrayLength);

        // 设置billboard点
        m_mesh = new Mesh();
        int pointLength = m_pointList.Length;
        Vector3[] vertices = new Vector3[pointLength];
        int[] indices = new int[pointLength];
        for (int i = 0; i < pointLength; ++i)
        {
            float x = m_pointList[i].position.x;
            float z = m_pointList[i].position.z;
            vertices[i] = new Vector3(x, GetGroundHeight(x, z), z);
            indices[i] = i;
        }
        m_mesh.vertices = vertices;
        m_mesh.SetIndices(indices, MeshTopology.Points, 0);
    }

    void Update()
    {
        Graphics.DrawMesh(m_mesh, Vector3.zero, Quaternion.identity, m_material, 0, Camera.main);
    }

    //通过Raycast计算广告牌的高度
    float GetGroundHeight(float x, float z)
    {
        RaycastHit hit;
        if (Physics.Raycast(new Vector3(x, 10, z), Vector3.down, out hit, 20))
        {
            return 10 - hit.distance + 1;
        }
        return 0;
    }
}
