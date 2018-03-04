Shader "Custom/CelMultipleLights"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_RampTex("Ramp", 2D) = "white" {}
		_Color("Color", Color) = (1, 1, 1, 1)
	}

	SubShader
	{
		// First light pass (main directional light)
		Pass
		{
			Tags
            {
                "LightMode" = "ForwardBase"
            }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
            #include "AutoLight.cginc"
			#include "UnityCG.cginc"
			
			// Properties
			sampler2D _MainTex;
			sampler2D _RampTex;
			float4 _Color;
			float4 _LightColor0; // provided by Unity

			struct vertexInput
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float3 texCoord : TEXCOORD0;
			};

			struct vertexOutput
			{
				float4 pos : SV_POSITION;
				float3 normal : NORMAL;
				float3 texCoord : TEXCOORD0;
			};

			vertexOutput vert(vertexInput input)
			{
				vertexOutput output;

				// convert input to world/ clip space
				output.pos = UnityObjectToClipPos(input.vertex);
				float4 normal4 = float4(input.normal, 0.0);
				output.normal = normalize(mul(normal4, unity_WorldToObject).xyz);

				output.texCoord = input.texCoord;

				return output;
			}

			float4 frag(vertexOutput input) : COLOR
			{
				// convert light direction to world space & normalize
				float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

				// finds location on ramp texture that we should sample
				// based on angle between surface normal and light direction
				float ramp = clamp(dot(input.normal, lightDir), 0.001, 1.0);
				float3 lighting = tex2D(_RampTex, float2(ramp, 0.5)).rgb;

				// sample texture for color
				float4 albedo = tex2D(_MainTex, input.texCoord.xy);

                // ambient light
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;

				float3 rgb = albedo.rgb * _LightColor0.rgb * lighting * _Color.rgb * ambient;
				return float4(rgb, _Color.a);
			}

			ENDCG
		}

        // Pass for additional lights
        Pass
		{
			Tags
            {
                "LightMode" = "ForwardAdd"
            }
            Blend One One

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
            #include "AutoLight.cginc"
			#include "UnityCG.cginc"
			
			// Properties
			sampler2D _MainTex;
			sampler2D _RampTex;
			float4 _Color;
			float4 _LightColor0; // provided by Unity

			struct vertexInput
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float3 texCoord : TEXCOORD0;
			};

			struct vertexOutput
			{
				float4 pos : SV_POSITION;
				float3 normal : NORMAL;
				float3 texCoord : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
			};

			vertexOutput vert(vertexInput input)
			{
				vertexOutput output;

				output.pos = UnityObjectToClipPos(input.vertex);
                output.posWorld = mul(unity_ObjectToWorld, input.vertex);
				float4 normal4 = float4(input.normal, 0.0);
				output.normal = normalize(mul(normal4, unity_WorldToObject).xyz);

				output.texCoord = input.texCoord;
				return output;
			}

			float4 frag(vertexOutput input) : COLOR
			{
				// determine strength of light
                // based on vertex distance from light
				float3 vertexToLightSource = _WorldSpaceLightPos0.xyz - input.posWorld.xyz;
                float distance = length(vertexToLightSource);
                float attenuation = 1 / distance; // linear attenuation 
                float3 lightDir = normalize(vertexToLightSource);

				// finds location on ramp texture that we should sample
				// based on angle between surface normal and light direction
				float ramp = clamp(dot(input.normal, lightDir), 0.001, 1.0);
				float3 lighting = tex2D(_RampTex, float2(ramp, 0.5)).rgb * attenuation;

				// sample texture for color
				float4 albedo = tex2D(_MainTex, input.texCoord.xy);

                // ambient light
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;

				float3 rgb = albedo.rgb * _LightColor0.rgb * lighting * _Color.rgb * ambient;
				return float4(rgb, _Color.a);
			}

			ENDCG
		}
	}
}
