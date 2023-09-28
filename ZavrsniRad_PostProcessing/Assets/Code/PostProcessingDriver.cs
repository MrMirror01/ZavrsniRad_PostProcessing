using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class PostProcessingDriver : MonoBehaviour
{
	public ThickOutlines thickOutlines;
	[Space(5)]
    public Blur blur;
	[Space(5)]
    public Sharpen sharpen;
	[Space(5)]
	public Bloom bloom;
	[Space(5)]
	public ToneMapping toneMapping;
	[Space(5)]
	public ColorCorrection colorCorrection;
	[Space(5)]
	public ChromaticAborration chromaticAborration;
	[Space(5)]
	public FilmGrain filmGrain;

	private void OnRenderImage(RenderTexture source, RenderTexture destination)
	{
		if (thickOutlines.active) thickOutlines.apply(source);
		if (blur.active) blur.apply(source);
		if (sharpen.active) sharpen.apply(source);
		if (bloom.active) bloom.apply(source);
		if (toneMapping.active) toneMapping.apply(source);
		if (colorCorrection.active) colorCorrection.apply(source);
		if (chromaticAborration.active) chromaticAborration.apply(source);
		if (filmGrain.active) filmGrain.apply(source);

		Graphics.Blit(source, destination);
	}
}
