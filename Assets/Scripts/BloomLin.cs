using System;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;
 
[Serializable]
[PostProcess(typeof(BloomLinRenderer), PostProcessEvent.AfterStack, "Custom/BloomLin")]
public sealed class BloomLin : PostProcessEffectSettings
{
    [Range(0f, 1f), Tooltip("BloomLin effect intensity.")]
    public FloatParameter intensity = new FloatParameter { value = 0.5f };
    public TextureParameter blurTexture = new TextureParameter {};
}
 
public sealed class BloomLinRenderer : PostProcessEffectRenderer<BloomLin>
{
    public override DepthTextureMode GetCameraFlags()
    {
        return DepthTextureMode.Depth;
    }

    public override void Render(PostProcessRenderContext context)
    {
        var sheet = context.propertySheets.Get(Shader.Find("Custom/Bloom"));
        sheet.properties.SetFloat("_Intensity", settings.intensity);
        sheet.properties.SetTexture("_BlurTex", settings.blurTexture);

        var cmd = context.command;
        cmd.BlitFullscreenTriangle(context.source, context.destination, sheet, 0);
    }
}