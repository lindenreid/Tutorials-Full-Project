Shader "Custom/Bloom"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_BlurTex("Blur Texture", 2D) = "white" {}
        _Intensity("Intensity", float) = 1.0
	}

	SubShader
	{
		Pass
		{
            Tags
            {
                "LightMode" = "ForwardBase"
            }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
            #include "UnityCG.cginc"

			// Properties
            sampler2D _MainTex;
            sampler2D _BlurTex;
            sampler2D _CameraDepthTexture; // provided by Unity
            float _Intensity;

            struct vertexInput
            {
                float4 vertex : POSITION;
                float4 texCoord : TEXCOORD0;  
            };

            struct vertexOutput
            {
                float4 pos: SV_POSITION;
                float4 texCoord : TEXCOORD0;
                float4 screenPos : TEXCOORD1;
            };

            vertexOutput vert(vertexInput input)
            {
                vertexOutput output;
                output.pos = UnityObjectToClipPos(input.vertex);
                output.texCoord = input.texCoord;
                output.screenPos = ComputeScreenPos(output.pos);
                return output;
            }

			float4 frag(vertexOutput input) : COLOR
			{
                // sample depth value on blur texture
                float4 depthSampleBlur = SAMPLE_DEPTH_TEXTURE_PROJ(_BlurTex, input.screenPos);
                float depthBlur = LinearEyeDepth(depthSampleBlur).r;

                // sample depth value on camera texture
                float4 depthSampleCam = SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, input.screenPos);
                float depthCam = LinearEyeDepth(depthSampleCam).r;

                // check if blur texture depth value is lower than camera depth value
                float blurCloser = depthBlur < depthCam;

                // sample both textures
                float4 base = tex2D(_MainTex, input.texCoord.xy);
                float4 blur = tex2D(_BlurTex, input.texCoord.xy) * _Intensity;
                
                return base + blur;
                //return float4(depthBlur, depthBlur, depthBlur, 1); // test blur texture depth sample
                //return float4(depthCam, depthCam, depthCam, 1); // test camera depth sample
			}

			ENDCG
		}
	}
}