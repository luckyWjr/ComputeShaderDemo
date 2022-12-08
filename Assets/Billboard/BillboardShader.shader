Shader "Billboard"
{
    Properties
    {
        _Textures("Texture Array", 2DArray) = "" {}
        _TextureCount("Texture Count", Int) = 1
        _Width("Width", Float) = 1.0
        _Height("Height", Float) = 2.0
    }

        SubShader
        {
            Tags { "RenderType" = "Opaque" }

            Pass
            {
                CGPROGRAM
                #pragma vertex vert
                #pragma geometry geom
                #pragma fragment frag

                #include "UnityCG.cginc"

                struct appdata
                {
                    float4 vertex : POSITION;
                    float2 uv : TEXCOORD0;
                };

                struct v2g
                {
                    float4 center : POSITION;
                };

                struct g2f
                {
                    float4 vertex : SV_POSITION;
                    float2 uv : TEXCOORD0;
                    uint primID : SV_PrimitiveID;
                };

                UNITY_DECLARE_TEX2DARRAY(_Textures);// texture array
                half _Width;
                half _Height;
                int _TextureCount;

                v2g vert(appdata v)
                {
                    v2g o;
                    // 变换到world space下
                    o.center = mul(UNITY_MATRIX_M, v.vertex);
                    return o;
                }

                [maxvertexcount(4)]
                void geom(point v2g gsIn[1], uint primID : SV_PrimitiveID, inout TriangleStream<g2f> triStream)
                {
                    half3 up = half3(0.0f, 1.0f, 0.0f);
                    half3 lookAt = _WorldSpaceCameraPos - gsIn[0].center;
                    lookAt.y = 0.0f;
                    lookAt = normalize(lookAt);
                    half3 left = cross(up, lookAt);

                    half halfWidth = 0.5f * _Width;
                    half halfHeight = 0.5f * _Height;

                    // 四个顶点的坐标和uv
                    half4 v[4];
                    v[0] = half4(gsIn[0].center + halfWidth * left - halfHeight * up, 1.0f);// 左下
                    v[1] = half4(gsIn[0].center + halfWidth * left + halfHeight * up, 1.0f);// 左上
                    v[2] = half4(gsIn[0].center - halfWidth * left - halfHeight * up, 1.0f);// 右下
                    v[3] = half4(gsIn[0].center - halfWidth * left + halfHeight * up, 1.0f);// 右上

                    // unity的uv左下角为(0,0)，而dx左上角为(0,0)
                    float2 uv[4] =
                    {
                        float2(0.0f, 0.0f),
                        float2(0.0f, 1.0f),
                        float2(1.0f, 0.0f),
                        float2(1.0f, 1.0f),
                    };

                    g2f o;
                    [unroll]
                    for (int i = 0; i < 4; ++i)
                    {
                        // 变换到裁剪空间
                        o.vertex = UnityObjectToClipPos(v[i]);
                        o.uv = uv[i];
                        o.primID = primID;

                        triStream.Append(o);
                    }
                }

                fixed4 frag(g2f i) : SV_Target
                {
                    // texture array 采样
                    fixed4 col = UNITY_SAMPLE_TEX2DARRAY(_Textures, fixed3(i.uv, i.primID % _TextureCount));
                    return col;
                }
                ENDCG
            }
        }
}
