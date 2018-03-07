Shader "Custom/Bloom"
{
	HLSLINCLUDE

    #include "../../PostProcessing-2/PostProcessing/Shaders/StdLib.hlsl"
    #include "../../PostProcessing-2/PostProcessing/Shaders/Colors.hlsl"
    #pragma target 3.0

    TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);
    TEXTURE2D_SAMPLER2D(_CameraDepthTexture, sampler_CameraDepthTexture);
    TEXTURE2D_SAMPLER2D(_BlurTex, sampler_BlurTex);
    float _Intensity;

    float4 Frag(VaryingsDefault i) : SV_TARGET
    {
        // sample depth values
        float4 depthCam = Linear01Depth( SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture, float2(i.texcoordStereo.x, i.texcoordStereo.y)) );
        float4 depthBlur = Linear01Depth( SAMPLE_DEPTH_TEXTURE(_BlurTex, sampler_BlurTex, float2(i.texcoordStereo.x, i.texcoordStereo.y)) );

        // check which pixel is closer
        float blurCloser = depthBlur.x < depthCam.x;

        // sample textures
        float4 base = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord.xy);
        float4 blur = SAMPLE_TEXTURE2D(_BlurTex, sampler_BlurTex, i.texcoord.xy);
        
        //return depthCam; // test camera depth sample
        return depthBlur; // test blur depth sample
        //return float4(blurCloser, blurCloser, blurCloser, 1); // check difference
    }

    ENDHLSL

    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
        }
        Cull Off
        ZWrite Off
        ZTest Always

        Pass 
        {
            HLSLPROGRAM
                #pragma vertex VertDefault 
                #pragma fragment Frag
            ENDHLSL
        }

    }
}