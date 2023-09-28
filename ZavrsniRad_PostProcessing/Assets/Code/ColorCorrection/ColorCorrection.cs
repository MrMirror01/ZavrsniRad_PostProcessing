using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[Serializable]
public class ColorCorrection : Effect
{
	[Range(-1.0f, 1.0f)]
	public float brightness;
	[Range(0.0f, 3.0f)]
	public float contrast;
	[Range(0.0f, 3.0f)]
	public float saturation;
	[Range(0.0f, 3.0f), Tooltip("Default value is 2.2")]
	public float gamma = 2.2f;

	public override void apply(RenderTexture tex)
	{
		if (mat == null)
		{
			mat = new Material(shader);
			mat.hideFlags = HideFlags.HideAndDontSave;
		}
		mat.SetFloat("_Swipe", swipe);
		mat.SetFloat("_Brightness", brightness);
		mat.SetFloat("_Contrast", contrast);
		mat.SetFloat("_Saturation", saturation);
		mat.SetFloat("_Gamma", gamma);

		Graphics.Blit(tex, tex, mat);
	}
}
