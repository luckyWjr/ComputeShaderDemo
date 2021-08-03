Shader "Custom/ShowDepthTexture"
{
    SubShader{
        Pass {
            Cull Off
            ZWrite Off
            ZTest Always

            CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag


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

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex.xyz);
                o.uv = v.uv;
                return o;
            }

            sampler2D _CameraDepthTexture;
            float4 frag(v2f input) : Color
            {
                float depth = tex2D(_CameraDepthTexture, input.uv);
                #if defined(UNITY_REVERSED_Z)
                    depth = 1 - depth;//d3d,metal
                #endif
                
                return float4(depth, 0, 0, 1.0f);
                //return float4(depth, depth, depth, 1.0f);
                //d3d gl3 android_vulkan gl2 metal 0-1
            }

            ENDCG
        }
    }
}
