using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class PostProcessingDriver : MonoBehaviour
{
	public ScreenSpaceAmbientOcclusion screenSpaceAmbientOcclusion;
	[Space(3)]
	public ThickOutlines thickOutlines;
	[Space(3)]
	public Fog fog;
	[Space(3)]
    public Blur blur;
	[Space(3)]
    public Sharpen sharpen;
	[Space(3)]
	public DepthOfField depthOfField;
	[Space(3)]
	public Bloom bloom;
	[Space(3)]
	public ToneMapping toneMapping;
	[Space(3)]
	public ColorQuantization colorQuantization;
	[Space(3)]
	public Dithering dithering;
	[Space(3)]
	public ColorCorrection colorCorrection;
	[Space(3)]
	public AdvancedColorCorrection advancedColorCorrection;
	[Space(3)]
	public ChromaticAborration chromaticAborration;
	[Space(3)]
	public FilmGrain filmGrain;

	private void Start()
	{
		//screenSpaceAmbientOcclusion.generateNoiseTexture();
	}

	private void OnRenderImage(RenderTexture source, RenderTexture destination)
	{
		if (screenSpaceAmbientOcclusion.active) screenSpaceAmbientOcclusion.apply(source);
		if (thickOutlines.active) thickOutlines.apply(source);
		if (fog.active) fog.apply(source);
		if (blur.active) blur.apply(source);
		if (sharpen.active) sharpen.apply(source);
		if (depthOfField.active) depthOfField.apply(source);
		if (bloom.active) bloom.apply(source);
		if (toneMapping.active) toneMapping.apply(source);
		if (colorQuantization.active) colorQuantization.apply(source);
		if (dithering.active) dithering.apply(source);
		if (colorCorrection.active) colorCorrection.apply(source);
		if (advancedColorCorrection.active) advancedColorCorrection.apply(source);
		if (chromaticAborration.active) chromaticAborration.apply(source);
		if (filmGrain.active) filmGrain.apply(source);

		Graphics.Blit(source, destination);
	}
}
