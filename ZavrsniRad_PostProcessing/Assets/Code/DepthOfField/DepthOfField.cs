using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[Serializable]
public class DepthOfField : Effect
{
	[Range(0.0f, 50.0f)]
	public float distance;
	[Range(0f, 20f)]
	public float radius;
	[Range(1, 25)]
	public int blurIterations;

	private Blur blur = new Blur();
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
		if (mat == null)
		{
			mat = new Material(Shader.Find("Hidden/DepthOfField"));
			mat.hideFlags = HideFlags.HideAndDontSave;
		}
		mat.SetFloat("_Distance", distance);
		mat.SetFloat("_Radius", radius);

		RenderTexture circleOfConfusion = new RenderTexture(tex);
		Graphics.Blit(tex, circleOfConfusion, mat, (int)Passes.GetCircleOfConfusion);
		Graphics.Blit(circleOfConfusion, circleOfConfusion, mat, (int)Passes.MaxFilterNear);
		Graphics.Blit(circleOfConfusion, circleOfConfusion, mat, (int)Passes.BoxBlurNear);
		mat.SetTexture("_CircleOfConfusion", circleOfConfusion);

		RenderTexture near = new RenderTexture(tex);
		Graphics.Blit(tex, near);
		RenderTexture far = new RenderTexture(tex);
		Graphics.Blit(tex, far, mat, (int)Passes.GetFar);

		blur.type = Blur.BlurType.OptimisedGaussianBlur;
		blur.iterations = blurIterations;
		blur.apply(near);
		blur.apply(far);

		mat.SetTexture("_Far", far);
		Graphics.Blit(tex, tex, mat, (int)Passes.MergeFar);
		mat.SetTexture("_Near", near);
		Graphics.Blit(tex, tex, mat, (int)Passes.MergeNear);

		near.Release();
		far.Release();
		circleOfConfusion.Release();
	}
}
