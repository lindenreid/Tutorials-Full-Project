Shader "Custom/Bloom"
{
	HLSLINCLUDE

    #include "../../PostProcessing-2/PostProcessing/Shaders/StdLib.hlsl"

    TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);
    TEXTURE2D_SAMPLER2D(_BlurTex, sampler_BlurTex);
    TEXTURE2D_SAMPLER2D(_CameraDepthTexture, sampler_CameraDepthTexture);
    float _Intensity;

    float4 Frag(VaryingsDefault i) : SV_TARGET
    {
        // sample depth value on blur texture
        float depthBlur = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_BlurTex, sampler_BlurTex, i.texcoordStereo));

        // sample depth value on camera texture;
        float depthCam = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture, i.texcoordStereo));

        // check if blur texture depth value is lower than camera depth value
        float blurCloser = depthBlur < depthCam;

        // sample both textures
        float4 base = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord.xy);
        float4 blur = SAMPLE_TEXTURE2D(_BlurTex, sampler_BlurTex, i.texcoord.xy);
        
        return base + float4(1,0,0,1);
        //return base + blur;
        //return float4(depthBlur, depthBlur, depthBlur, 1); // test blur texture depth sample
        //return float4(depthCam, depthCam, depthCam, 1); // test camera depth sample
    }

    ENDHLSL

    SubShader
    {
        Cull Off ZWrite Off ZTest Always 

        Pass 
        {
            HLSLPROGRAM
                #pragma vertex VertDefault 
                #pragma fragment Frag
            ENDHLSL
        }

    }
}