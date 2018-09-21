Shader "Custom/SparkleSnow"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_RampTex("Ramp", 2D) = "white" {}
		_Color("Color", Color) = (1, 1, 1, 1)
        _SnowLevel("Snow Level", Range(0.01, -0.01)) = 0
        _SnowColor("Snow Color", Color) = (1, 1, 1, 1)
        _SnowRamp("Snow Ramp Texture", 2D) = "white" {}
        _SnowSparkle("Snow Sparkle Texture", 2D) = "white" {}
        _SnowDirection("Snow Direction", vector) = (1, 1, 1, 1)
		_SparklePow("Sparkle Brightness", float) = 1.5
		_SparkleColor("Sparkle Color", Color) =  (1,1,1,1)
	}

	SubShader
	{
		// Regular color & lighting pass
		Pass
		{
            Tags
			{ 
				"LightMode" = "ForwardBase" // allows shadow rec/cast
			}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase // shadows
			#include "AutoLight.cginc"
			#include "UnityCG.cginc"
			#include "random.cginc"

			// Properties
			sampler2D _MainTex;
			sampler2D _RampTex;
            sampler2D _SnowRamp;
            sampler2D _SnowSparkle;
            float4 _Color;
			float4 _SnowColor;
            float4 _SnowDirection;
            float _SnowLevel;
			float4 _LightColor0; // provided by Unity
			float _SparklePow;
			float4 _SparkleColor;

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
                float4 snowDir : TEXCOORD1;
				float3 viewDir : TEXCOORD2;
				LIGHTING_COORDS(3,4) // shadows
			};

			vertexOutput vert(vertexInput input)
			{
				vertexOutput output;

				// convert input to world space
				output.pos = UnityObjectToClipPos(input.vertex);
				output.normal = normalize(mul(float4(input.normal, 0.0), unity_WorldToObject).xyz);
                output.snowDir = mul(_SnowDirection, unity_WorldToObject);
				output.viewDir = normalize(_WorldSpaceCameraPos - mul(unity_ObjectToWorld, input.vertex).xyz);

                // texture coordinates
				output.texCoord = input.texCoord;

                TRANSFER_VERTEX_TO_FRAGMENT(output); // shadows
				return output;
			}

			float4 frag(vertexOutput input) : COLOR
			{
				// normalize light direction
				float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

                // apply regular lighting
                float2 ramp = float2(clamp(dot(input.normal, lightDir), 0, 1.0), 0.0);
				float3 lighting = tex2D(_RampTex, ramp).rgb;
				
				// sample texture & apply Color
				float4 albedo = tex2D(_MainTex, input.texCoord.xy);
                albedo *= _Color;

                // check if snow should be applied
                float applySnow = dot(input.normal, input.snowDir) >= _SnowLevel;

                // apply snow color
                albedo = (1-applySnow)*albedo + applySnow*_SnowColor;

				// apply sparkles (generated normals)
				float noisev = tex2D(_SnowSparkle, input.texCoord.xy);
				float spec = saturate(dot(reflect(-input.viewDir, input.normal), lightDir));
				float3 fp = frac(input.texCoord.xyz + 9*noisev + input.viewDir);
				fp *= (1 - fp);
				float glitter = saturate(1 - 3*(fp.x + fp.y + fp.z)); 
				float3 sparkle = glitter * pow(spec, _SparklePow) * _SparkleColor.rgb;
				 
				//float3 snowLighting = float3(noisev, noisev, noisev); // test noise
				//float3 snowLighting = float3(spec, spec, spec); // test spec
				//float3 snowLighting = fp; // test random val
				//float3 snowLighting = float3(glitter, glitter, glitter); // test glitter
				float3 snowLighting = sparkle; // test sparkle only
				//float3 snowLighting = tex2D(_SnowRamp, ramp).rgb + sparkle; // combined
                
				/*// apply sparkles (bump map)
				float4 sparkleTex = tex2D(_SnowSparkle, input.texCoord.xy);
				float3 sparkle = sparkleTex.rgb;
				float3 normal = normalize(input.normal + sparkle);
				float snowBump = saturate(dot(input.viewDir, normal));

				float3 snowSparkle = tex2D(_SnowRamp, float2(snowBump, 0.5)).rgb;
				//float3 snowLighting = sparkle;// test sparkle texture
				//float3 snowLighting = normal; // test normals
				//float3 snowLighting = float3(snowBump, snowBump, snowBump);// test bump value
				//float3 snowLighting = snowSparkle; // test just sparkle
				float3 snowLighting = tex2D(_SnowRamp, ramp).rgb + snowSparkle; // combined regular and sparkle lighting
				*/

                // use either snow lighting or regular lighting
                lighting = (1-applySnow)*lighting + applySnow*snowLighting;

                // shadows
				float attenuation = LIGHT_ATTENUATION(input); 

				float3 rgb = albedo.rgb * _LightColor0.rgb * lighting * attenuation;
				return float4(rgb, 1.0);
			}

			ENDCG
		}

		// Shadow pass
		/*Pass
    	{
            Tags 
			{
				"LightMode" = "ShadowCaster"
			}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster
            #include "UnityCG.cginc"

            struct v2f { 
                V2F_SHADOW_CASTER;
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
    	}*/
	}
}