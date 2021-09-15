Shader "Custom/DepthTextureMipmapCalculator"
{
    Properties{
        [HideInInspector] _MainTex("Previous Mipmap", 2D) = "black" {}
    }
        SubShader{
            Pass {
                Cull Off
                ZWrite Off
                ZTest Always

                CGPROGRAM
                #pragma target 3.0
                #pragma vertex vert
                #pragma fragment frag

                sampler2D _MainTex;
                float4 _MainTex_TexelSize;

                struct appdata
                {
                    float4 vertex : POSITION;
                    float2 uv : TEXCOORD0;
                };
                struct v2f
                {
                    float4 vertex : SV_POSITION;
                    float2 uv : TEXCOORD0;
                };

                inline float CalculatorMipmapDepth(float2 uv)
                {
                    float4 depth;
                    float offset = _MainTex_TexelSize.x / 2;
                    depth.x = tex2D(_MainTex, uv);
                    depth.y = tex2D(_MainTex, uv + float2(0, offset));
                    depth.z = tex2D(_MainTex, uv + float2(offset, 0));
                    depth.w = tex2D(_MainTex, uv + float2(offset, offset));
    #if defined(UNITY_REVERSED_Z)
                    return min(min(depth.x, depth.y), min(depth.z, depth.w));
    #else
                    return max(max(depth.x, depth.y), max(depth.z, depth.w));
    #endif
                }
                v2f vert(appdata v)
                {
                    v2f o;
                    o.vertex = UnityObjectToClipPos(v.vertex.xyz);
                    o.uv = v.uv;
                    return o;
                }
                float4 frag(v2f input) : Color
                {
                    float depth = CalculatorMipmapDepth(input.uv);
                    return float4(depth, 0, 0, 1.0f);
                }
                ENDCG
            }
        }
}