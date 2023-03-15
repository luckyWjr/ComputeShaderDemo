using System.Collections;
using System.Collections.Generic;
using UnityEngine;

//[ExecuteInEditMode]
public class BlurController : MonoBehaviour
{
    [SerializeField] bool m_isUsedComputeShader;
    [SerializeField] ComputeShader m_computeShader;
    [SerializeField] Material m_gaussianBlurMaterial;
    [SerializeField] Material m_computeShaderMaterial;
    [SerializeField] float m_gaussianSigma;

    int m_horzBlurKernel, m_vertBlurKernel, m_horzBlurPass, m_vertBlurPass;
    int m_ruler;// cs里的array一个元素占用一个寄存器，ps里不是
    RenderTexture m_horzResult, m_vertResult;// 存储水平模糊和垂直模糊后的结果
    float[] m_gaussianKernel;

    void Start()
    {
        m_horzBlurKernel = m_computeShader.FindKernel("HorzBlurCS");
        m_vertBlurKernel = m_computeShader.FindKernel("VertBlurCS");
        m_horzBlurPass = m_gaussianBlurMaterial.FindPass("HorzBlurPass");
        m_vertBlurPass = m_gaussianBlurMaterial.FindPass("VertBlurPass");

        m_horzResult = new RenderTexture(Screen.width, Screen.height, 0);
        m_horzResult.enableRandomWrite = true;
        m_horzResult.antiAliasing = 1;
        m_horzResult.useMipMap = false;

        m_vertResult = new RenderTexture(Screen.width, Screen.height, 0);
        m_vertResult.enableRandomWrite = true;
        m_vertResult.antiAliasing = 1;
        m_vertResult.useMipMap = false;

        m_ruler = m_isUsedComputeShader ? 4 : 1;

        m_gaussianKernel = GetGaussianBlurKernel(m_gaussianSigma);
        int radius = m_gaussianKernel.Length / m_ruler / 2;
        if (m_isUsedComputeShader)
        {
            m_computeShader.SetInt("radius", radius);
            m_computeShader.SetFloats("weights", m_gaussianKernel);

            m_computeShader.SetTexture(m_horzBlurKernel, "result", m_horzResult);
            m_computeShader.SetTexture(m_vertBlurKernel, "source", m_horzResult);
            m_computeShader.SetTexture(m_vertBlurKernel, "result", m_vertResult);
        }
        else
        {
            m_gaussianBlurMaterial.SetInt("radius", radius);
            m_gaussianBlurMaterial.SetFloatArray("weights", m_gaussianKernel);
            m_horzResult.enableRandomWrite = false;
        }
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (m_isUsedComputeShader)
        {
            m_computeShader.SetTexture(m_horzBlurKernel, "source", source);
            m_computeShader.Dispatch(m_horzBlurKernel, Mathf.CeilToInt(source.width / 256.0f), source.height, 1);

            m_computeShader.Dispatch(m_vertBlurKernel, source.width, Mathf.CeilToInt(source.height / 256.0f), 1);
            Graphics.Blit(m_vertResult, destination, m_computeShaderMaterial);
        }
        else
        {
            Graphics.Blit(source, m_horzResult, m_gaussianBlurMaterial, m_horzBlurPass);
            Graphics.Blit(m_horzResult, destination, m_gaussianBlurMaterial, m_vertBlurPass);
        }
    }

    // 计算一维的高斯模糊核
    float[] GetGaussianBlurKernel(float sigma)
    {
        int radius = (int)Mathf.Ceil(2.0f * sigma);
        float twoSigma2 = 2.0f * sigma * sigma;
        float weightSum = 0.0f;

        float[] weights = new float[(2 * radius + 1)];
        for (int i = -radius; i <= radius; ++i)
        {
            weights[i + radius] = Mathf.Exp(- i * i / twoSigma2);
            weightSum += weights[i + radius];
        }

        float[] kernel = new float[weights.Length * m_ruler];
        for (int i = 0; i < weights.Length; ++i)
            kernel[i * m_ruler] = weights[i] / weightSum;

        return kernel;
    }

    void OnDestroy()
    {
        m_horzResult.Release();
        m_vertResult.Release();
    }
}
