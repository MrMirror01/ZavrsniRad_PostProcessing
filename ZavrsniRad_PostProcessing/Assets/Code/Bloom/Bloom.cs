using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[Serializable]
public class Bloom : Effect
{
	[Range(1, 16), Tooltip("Strenght of blur")]
	public int iterations = 1;
	[Range(0, 10)]
	public float intensity = 1;
	[Range(0, 10), Tooltip("LDR 0-1, HDR >1")]
	public float threshold = 0.9f;
	[Range(0, 1)]
	public float softThreshold = 0.5f;

	public bool debug;

	const int prefilterPass = 0;
	const int downsampleingPass = 1;
	const int upsampleingPass = 2;
	const int applyBloomPass = 3;
	const int debugBloomPass = 4;

	public override void apply(RenderTexture tex)
	{
		if (mat == null)
		{
			mat = new Material(shader);
			mat.hideFlags = HideFlags.HideAndDontSave;
		}
		//calculates the soft knee function for the treshold
		float knee = threshold * softThreshold;
		Vector4 filter; // {treshold, treshold - knee, 2 * knee, 0.25 / knee}
		filter.x = threshold;
		filter.y = threshold - knee;
		filter.z = 2f * knee;
		filter.w = 0.25f / (knee + 0.00001f);

		mat.SetFloat("_Swipe", swipe);
		mat.SetVector("_Filter", filter);
		mat.SetFloat("_Intensity", Mathf.GammaToLinearSpace(intensity));

		RenderTexture[] textures = new RenderTexture[16];

		int width = tex.width / 2;
		int height = tex.height / 2;
		RenderTextureFormat format = tex.format;

		RenderTexture currentDestination = textures[0] = RenderTexture.GetTemporary(
			width, height, 0, format
		);
		Graphics.Blit(tex, currentDestination, mat, prefilterPass);

		RenderTexture currentSource = currentDestination;

		int i = 1;
		for (; i < iterations; i++)
		{
			width /= 2;
			height /= 2;
			if (height <= 2 || width <= 2) break;
			currentDestination = textures[i] = RenderTexture.GetTemporary(width, height, 0, format);
			Graphics.Blit(currentSource, currentDestination, mat, downsampleingPass);
			currentSource = currentDestination;
		}

		for (i -= 2; i >= 0; i--)
		{
			currentDestination = textures[i];
			textures[i] = null;
			Graphics.Blit(currentSource, currentDestination, mat, upsampleingPass);
			RenderTexture.ReleaseTemporary(currentSource);
			currentSource = currentDestination;
		}

		if (debug)
		{
			Graphics.Blit(currentSource, tex, mat, debugBloomPass);
		}
		else
		{
			mat.SetTexture("_SourceTex", tex);
			Graphics.Blit(currentSource, tex, mat, applyBloomPass);
		}


		RenderTexture.ReleaseTemporary(currentSource);
		RenderTexture.ReleaseTemporary(currentDestination);
	}
}
