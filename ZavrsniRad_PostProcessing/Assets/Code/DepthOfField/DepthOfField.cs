using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;

[Serializable]
public class DepthOfField : Effect
{
	[Range(0.0f, 50.0f)]
	public float distance;
	[Range(0f, 40f)]
	public float radius;
	[Range(0f, 10f)]
	public float blurKernelSize;
	public bool inverseToneMapping;
	[Range(0.5f, 2f)]
	public float invereseToneMapWhitepoint;
	[Tooltip("Excentuates highlights. May lead to artefacts.")]
	public bool inverseKarisAverage;

	private Material swipeMat;
	private Blur blur = new Blur();
	private ToneMapping toneMapping = new ToneMapping();
	private enum Passes
	{
		GetCircleOfConfusion = 0,
		MaxFilterNear = 1,
		BoxBlurNear = 2,
		GetFar = 3,
		MergeFar = 4,
		MergeNear = 5,
	}

	public override void apply(RenderTexture tex)
	{
		if (swipeMat == null)
		{
			swipeMat = new Material(Shader.Find("Hidden/Swipe"));
			swipeMat.hideFlags = HideFlags.HideAndDontSave;
		}
		swipeMat.SetFloat("_Swipe", swipe);
		if (mat == null)
		{
			mat = new Material(Shader.Find("Hidden/DepthOfField"));
			mat.hideFlags = HideFlags.HideAndDontSave;
		}
		mat.SetFloat("_Distance", distance);
		mat.SetFloat("_Radius", radius);

		RenderTexture source = RenderTexture.GetTemporary(tex.descriptor);
		Graphics.Blit(tex, source);

		//inverse tonemapping
		if (inverseToneMapping)
		{
			toneMapping.toneMapper = ToneMapping.ToneMapper.InverseReinhardExtended;
			toneMapping.whitePoint = invereseToneMapWhitepoint;
			toneMapping.apply(source);
		}

		RenderTexture circleOfConfusion = RenderTexture.GetTemporary(source.descriptor);
		Graphics.Blit(source, circleOfConfusion, mat, (int)Passes.GetCircleOfConfusion);
		mat.SetFloat("_BlurKernelSize", blurKernelSize);
		Graphics.Blit(circleOfConfusion, circleOfConfusion, mat, (int)Passes.MaxFilterNear);
		Graphics.Blit(circleOfConfusion, circleOfConfusion, mat, (int)Passes.BoxBlurNear);
		mat.SetTexture("_CircleOfConfusion", circleOfConfusion);

		RenderTexture near = RenderTexture.GetTemporary(source.descriptor);
		Graphics.Blit(source, near);
		RenderTexture far = RenderTexture.GetTemporary(source.descriptor);
		Graphics.Blit(source, far, mat, (int)Passes.GetFar);

		if (inverseKarisAverage) blur.type = Blur.BlurType.BokehBlurWithInverseKarisAverge;
		else blur.type = Blur.BlurType.BokehBlur;
		blur.iterations = 1;
		blur.kernelSize = blurKernelSize;
		blur.apply(near);
		blur.apply(far);

		mat.SetTexture("_Far", far);
		Graphics.Blit(source, source, mat, (int)Passes.MergeFar);
		mat.SetTexture("_Near", near);
		Graphics.Blit(source, source, mat, (int)Passes.MergeNear);

		if (inverseToneMapping)
		{
			toneMapping.toneMapper = ToneMapping.ToneMapper.ReinhardExtended;
			toneMapping.apply(source);
		}

		swipeMat.SetTexture("_OtherTex", source);
		Graphics.Blit(tex, tex, swipeMat);

		RenderTexture.ReleaseTemporary(near);
		RenderTexture.ReleaseTemporary(far);
		RenderTexture.ReleaseTemporary(circleOfConfusion);
		RenderTexture.ReleaseTemporary(source);
	}
}
