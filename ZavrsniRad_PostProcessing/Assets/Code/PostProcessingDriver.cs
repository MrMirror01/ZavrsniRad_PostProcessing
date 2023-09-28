using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class PostProcessingDriver : MonoBehaviour
{
	public ThickOutlines thickOutlines;
	[Space(10)]
    public Blur blur;
	[Space(10)]
    public Sharpen sharpen;
	[Space(10)]
	public Bloom bloom;
	[Space(10)]
	public ColorCorrection colorCorrection;
	[Space(10)]
	public FilmGrain filmGrain;

	private void OnRenderImage(RenderTexture source, RenderTexture destination)
	{
		if (thickOutlines.active) thickOutlines.apply(source);
		if (blur.active) blur.apply(source);
		if (sharpen.active) sharpen.apply(source);
		if (bloom.active) bloom.apply(source);
		if (filmGrain.active) filmGrain.apply(source);
		if (colorCorrection.active) colorCorrection.apply(source);

		Graphics.Blit(source, destination);
	}
}
