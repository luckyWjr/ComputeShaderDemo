Shader "Unlit/InstanceGrass"
{
	Properties
	{
		[NoScaleOffset] [Header(Surface)] [Space] _MainTex("Main Texture", 2D) = "white" {}
		_Metallic("Metallic", Range(0 , 1)) = 0
		_Smoothness("Smoothness", Range(0 , 1)) = 0
		[Header(Main Bending)][Space]_MBDefaultBending("MB Default Bending", Float) = 0
		[Space]_MBAmplitude("MB Amplitude", Float) = 1.5
		_MBAmplitudeOffset("MB Amplitude Offset", Float) = 2
		[Space]_MBFrequency("MB Frequency", Float) = 1.11
		_MBFrequencyOffset("MB Frequency Offset", Float) = 0
		[Space]_MBPhase("MB Phase", Float) = 1
		[Space]_MBWindDir("MB Wind Dir", Range(0 , 360)) = 0
		_MBWindDirOffset("MB Wind Dir Offset", Range(0 , 180)) = 20
		[Space]_MBMaxHeight("MB Max Height", Float) = 10
		[NoScaleOffset][Header(World Space Noise)][Space]_NoiseTexture("Noise Texture", 2D) = "bump" {}
		_NoiseTextureTilling("Noise Tilling - Static (XY), Animated (ZW)", Vector) = (1,1,1,1)
		_NoisePannerSpeed("Noise Panner Speed", Vector) = (0.05,0.03,0,0)
		[HideInInspector] _texcoord("", 2D) = "white" {}
		[HideInInspector] __dirty("", Int) = 1
	}

		SubShader
		{
			Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
			Cull Back
			CGPROGRAM
			#include "UnityShaderVariables.cginc"
			#pragma target 4.5
			#pragma multi_compile_instancing
			#pragma surface surf Standard keepalpha addshadow fullforwardshadows vertex:vertexDataFunc
			#pragma instancing_options procedural:setup

			struct Input
			{
				float2 uv_texcoord;
			};

			uniform float _MBWindDir;
			uniform float _MBWindDirOffset;
			uniform sampler2D _NoiseTexture;
			uniform float4 _NoiseTextureTilling;
			uniform float2 _NoisePannerSpeed;
			uniform float _MBAmplitude;
			uniform float _MBAmplitudeOffset;
			uniform float _MBFrequency;
			uniform float _MBFrequencyOffset;
			uniform float _MBPhase;
			uniform float _MBDefaultBending;
			uniform float _MBMaxHeight;
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform float _Metallic;
			uniform float _Smoothness;


			float3 RotateAroundAxis(float3 center, float3 original, float3 u, float angle)
			{
				original -= center;
				float C = cos(angle);
				float S = sin(angle);
				float t = 1 - C;
				float m00 = t * u.x * u.x + C;
				float m01 = t * u.x * u.y - S * u.z;
				float m02 = t * u.x * u.z + S * u.y;
				float m10 = t * u.x * u.y + S * u.z;
				float m11 = t * u.y * u.y + C;
				float m12 = t * u.y * u.z - S * u.x;
				float m20 = t * u.x * u.z - S * u.y;
				float m21 = t * u.y * u.z + S * u.x;
				float m22 = t * u.z * u.z + C;
				float3x3 finalMatrix = float3x3(m00, m01, m02, m10, m11, m12, m20, m21, m22);
				return mul(finalMatrix, original) + center;
			}


			void vertexDataFunc(inout appdata_full v, out Input o)
			{
				UNITY_INITIALIZE_OUTPUT(Input, o);
				float MB_WindDirection870 = _MBWindDir;
				float MB_WindDirectionOffset1373 = _MBWindDirOffset;
				float3 objToWorld1645 = mul(unity_ObjectToWorld, float4(float3(0,0,0), 1)).xyz;
				float2 appendResult1506 = (float2(objToWorld1645.x , objToWorld1645.z));
				float2 WorldSpaceUVs1638 = appendResult1506;
				float2 AnimatedNoiseTilling1639 = (_NoiseTextureTilling).zw;
				float2 panner1643 = (0.1 * _Time.y * _NoisePannerSpeed + float2(0,0));
				float4 AnimatedWorldNoise1344 = tex2Dlod(_NoiseTexture, float4(((WorldSpaceUVs1638 * AnimatedNoiseTilling1639) + panner1643), 0, 0.0));
				float temp_output_1584_0 = radians(((MB_WindDirection870 + (MB_WindDirectionOffset1373 * (-1.0 + ((AnimatedWorldNoise1344).r - 0.0) * (1.0 - -1.0) / (1.0 - 0.0)))) * -1.0));
				float3 appendResult1587 = (float3(cos(temp_output_1584_0) , 0.0 , sin(temp_output_1584_0)));
				float3 worldToObj1646 = mul(unity_WorldToObject, float4(appendResult1587, 1)).xyz;
				float3 worldToObj1647 = mul(unity_WorldToObject, float4(float3(0,0,0), 1)).xyz;
				float3 normalizeResult1581 = normalize((worldToObj1646 - worldToObj1647));
				float3 MB_RotationAxis1420 = normalizeResult1581;
				float MB_Amplitude880 = _MBAmplitude;
				float MB_AmplitudeOffset1356 = _MBAmplitudeOffset;
				float2 StaticNoileTilling1640 = (_NoiseTextureTilling).xy;
				float4 StaticWorldNoise1340 = tex2Dlod(_NoiseTexture, float4((WorldSpaceUVs1638 * StaticNoileTilling1640), 0, 0.0));
				float3 objToWorld1649 = mul(unity_ObjectToWorld, float4(float3(0,0,0), 1)).xyz;
				float MB_Frequency873 = _MBFrequency;
				float MB_FrequencyOffset1474 = _MBFrequencyOffset;
				float MB_Phase1360 = _MBPhase;
				float MB_DefaultBending877 = _MBDefaultBending;
				float3 ase_vertex3Pos = v.vertex.xyz;
				float MB_MaxHeight1335 = _MBMaxHeight;
				float MB_RotationAngle97 = radians(((((MB_Amplitude880 + (MB_AmplitudeOffset1356 * (StaticWorldNoise1340).r)) * sin((((objToWorld1649.x + objToWorld1649.z) + (_Time.y * (MB_Frequency873 + (MB_FrequencyOffset1474 * (StaticWorldNoise1340).r)))) * MB_Phase1360))) + MB_DefaultBending877) * (ase_vertex3Pos.y / MB_MaxHeight1335)));
				float3 appendResult1558 = (float3(0.0 , ase_vertex3Pos.y , 0.0));
				float3 rotatedValue1567 = RotateAroundAxis(appendResult1558, ase_vertex3Pos, MB_RotationAxis1420, MB_RotationAngle97);
				float3 rotatedValue1565 = RotateAroundAxis(float3(0,0,0), rotatedValue1567, MB_RotationAxis1420, MB_RotationAngle97);
				float3 LocalVertexOffset1045 = ((rotatedValue1565 - ase_vertex3Pos) * step(0.01 , ase_vertex3Pos.y));
				v.vertex.xyz += LocalVertexOffset1045;
				v.vertex.w = 1;
			}

			#ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
			StructuredBuffer<float4x4> positionBuffer;
			#endif

			void setup()
			{
			#ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
				unity_ObjectToWorld = positionBuffer[unity_InstanceID];
				unity_WorldToObject = unity_ObjectToWorld;
				unity_WorldToObject._14_24_34 *= -1;
				unity_WorldToObject._11_22_33 = 1.0f / unity_WorldToObject._11_22_33;
			#endif
			}

			void surf(Input i , inout SurfaceOutputStandard o)
			{
				float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 Albedo292 = tex2D(_MainTex, uv_MainTex);
				o.Albedo = Albedo292.rgb;
				o.Metallic = _Metallic;
				o.Smoothness = _Smoothness;
				o.Alpha = 1;
			}

			ENDCG
		}
		Fallback "Diffuse"
		CustomEditor "LPVegetation_MaterialInspector"
}
