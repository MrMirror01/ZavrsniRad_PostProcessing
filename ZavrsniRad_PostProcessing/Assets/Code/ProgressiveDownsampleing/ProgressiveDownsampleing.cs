using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[Serializable]
public class ProgressiveDownsampleing : Effect
{
	[Range(1, 16)]
	public int iterations = 1;
	public FilterMode filterMode;

	public override void apply(RenderTexture tex)
	{
		if (mat == null)
		{
			mat = new Material(Shader.Find("Hidden/Swipe"));
			mat.hideFlags = HideFlags.HideAndDontSave;
		}

		RenderTexture[] textures = new RenderTexture[16];

		int width = tex.width / 2;
		int height = tex.height / 2;
		RenderTextureFormat format = tex.format;

		RenderTexture currentDestination = textures[0] = RenderTexture.GetTemporary(
			width, height, 0, format
		);
		currentDestination.filterMode = filterMode;
		Graphics.Blit(tex, currentDestination);

		RenderTexture currentSource = currentDestination;

		int i = 1;
		for (; i < iterations; i++)
		{
			width /= 2;
			height /= 2;
			if (height <= 2 || width <= 2) break;
			currentDestination = textures[i] = RenderTexture.GetTemporary(width, height, 0, format);
			currentDestination.filterMode = filterMode;
			Graphics.Blit(currentSource, currentDestination);
			currentSource = currentDestination;
		}

		for (i -= 2; i >= 0; i--)
		{
			currentDestination = textures[i];
			textures[i] = null;
			Graphics.Blit(currentSource, currentDestination);
			RenderTexture.ReleaseTemporary(currentSource);
			currentSource = currentDestination;
		}

		mat.SetTexture("_OtherTex", currentSource);
		mat.SetFloat("_Swipe", swipe);
		Graphics.Blit(tex, tex, mat);

		RenderTexture.ReleaseTemporary(currentSource);
		RenderTexture.ReleaseTemporary(currentDestination);
	}
}
