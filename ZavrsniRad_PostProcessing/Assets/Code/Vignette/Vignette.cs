using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[Serializable]
public class Vignette : Effect
{
	[Range(-1f, 1f)]
	public float intensity;
	[Range(.001f, 100f)]
	public float falloff;
	public bool round;

	public override void apply(RenderTexture tex)
	{
		if (mat == null)
		{
			mat = new Material(Shader.Find("Hidden/Vignette"));
			mat.hideFlags = HideFlags.HideAndDontSave;
		}
		mat.SetFloat("_Swipe", swipe);
		mat.SetFloat("_Intensity", intensity);
		mat.SetFloat("_Falloff", falloff);
		mat.SetInt("_Round", round ? 1 : 0);

		Graphics.Blit(tex, tex, mat);
	}
}
