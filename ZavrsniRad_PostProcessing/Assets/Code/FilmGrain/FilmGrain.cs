using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[Serializable]
public class FilmGrain : Effect
{
	[Range(0f, 1f)]
	public float intensity = 0.1f;

	public override void apply(RenderTexture tex)
	{
		if (mat == null)
		{
			mat = new Material(Shader.Find("Hidden/FilmGrain"));
			mat.hideFlags = HideFlags.HideAndDontSave;
		}
		mat.SetFloat("_Swipe", swipe);
		mat.SetFloat("_Intensity", intensity);

		Graphics.Blit(tex, tex, mat);
	}
}
