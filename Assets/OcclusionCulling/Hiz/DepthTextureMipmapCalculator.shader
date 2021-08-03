Shader "Custom/DepthTextureMipmapCalculator"
{
    Properties{
        [HideInInspector] _DepthTexture("Depth Texture", 2D) = "black" {}
        [HideInInspector] _UVSizePerPixel("UV Size Per Pixel", Vector) = (0, 0, 0, 0)
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
            //#pragma enable_d3d11_debug_symbols

            sampler2D _DepthTexture;
            float4 _UVSizePerPixel;

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

            inline float CalculatorMipmapDepth(sampler2D  preMipmap, float2 uv, float2 uvSize)
            {
                float4 depth;
                float2 uv0 = uv + float2(-0.25f, -0.25f) * uvSize;
                float2 uv1 = uv + float2(0.25f, -0.25f) * uvSize;
                float2 uv2 = uv + float2(-0.25f, 0.25f) * uvSize;
                float2 uv3 = uv + float2(0.25f, 0.25f) * uvSize;

                depth.x = tex2D(preMipmap, uv0);
                depth.y = tex2D(preMipmap, uv1);
                depth.z = tex2D(preMipmap, uv2);
                depth.w = tex2D(preMipmap, uv3);

//#if defined(UNITY_REVERSED_Z)
                return min(min(depth.x, depth.y), min(depth.z, depth.w));
//#else
                //return max(max(depth.x, depth.y), max(depth.z, depth.w));
//#endif
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
                float2 uvSize = _UVSizePerPixel.xy;
                float2 uv = input.uv;
                float depth = CalculatorMipmapDepth(_DepthTexture, uv, uvSize);
                return float4(depth, 0, 0, 1.0f);
            }

            ENDCG
        }
    }
}
