using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;

[ExecuteInEditMode]
public class PostProcessingDriver : MonoBehaviour
{
	//public SSAO ssao;
	//[Space(3)]
	public ThickOutlines thickOutlines;
	[Space(3)]
	public Fog fog;
	[Space(3)]
    public Blur blur;
	[Space(3)]
    public Sharpen sharpen;
	[Space(3)]
	public Bloom bloom;
	[Space(3)]
	public DepthOfField depthOfField;
	[Space(3)]
	public ChromaticAborration chromaticAborration;
	[Space(3)]
	public FilmGrain filmGrain;
	[Space(3)]
	public Vignette vignette;
	[Space(3)]
	public ColorCorrection colorCorrection;
	[Space(3)]
	public AdvancedColorCorrection advancedColorCorrection;
	[Space(3)]
	public ToneMapping toneMapping;
	[Space(3)]
	public ColorQuantization colorQuantization;
	[Space(3)]
	public ProgressiveDownsampleing progressiveDownsampleing;
	[Space(3)]
	public Dithering dithering;

	private void Start()
	{
		//ssao.generateNoiseTexture();
	}

	private void OnRenderImage(RenderTexture source, RenderTexture destination)
	{
		//Material mat = new Material(Shader.Find("Hidden/TESTSHADER"));
		//Graphics.Blit(source, source, mat);

		/*Texture2D renderTex = new Texture2D(source.width, source.height);

		renderTex.ReadPixels(new Rect(0, 0, renderTex.width, renderTex.height), 0, 0);
		renderTex.Apply();

		byte[] bytes = renderTex.EncodeToPNG();
		File.WriteAllBytes(Application.dataPath + @"\Code\test.png", bytes);*/

		//if (ssao.active) ssao.apply(source);
		if (thickOutlines.active) thickOutlines.apply(source);
		if (fog.active) fog.apply(source);
		if (blur.active) blur.apply(source);
		if (sharpen.active) sharpen.apply(source);
		if (bloom.active) bloom.apply(source);
		if (depthOfField.active) depthOfField.apply(source);
		if (chromaticAborration.active) chromaticAborration.apply(source);
		if (filmGrain.active) filmGrain.apply(source);
		if (vignette.active) vignette.apply(source);
		if (colorCorrection.active) colorCorrection.apply(source);
		if (advancedColorCorrection.active) advancedColorCorrection.apply(source);
		if (toneMapping.active) toneMapping.apply(source);
		if (colorQuantization.active) colorQuantization.apply(source);
		if (progressiveDownsampleing.active) progressiveDownsampleing.apply(source);
		if (dithering.active) dithering.apply(source);

		/*Texture2D TEX = new Texture2D(source.width, source.height);

		TEX.ReadPixels(new Rect(0, 0, TEX.width, TEX.height), 0, 0);
		TEX.Apply();

		byte[] bytes = TEX.EncodeToPNG();
		File.WriteAllBytes(Application.dataPath + @"\Code\test.png", bytes);*/

		Graphics.Blit(source, destination);
	}
}
