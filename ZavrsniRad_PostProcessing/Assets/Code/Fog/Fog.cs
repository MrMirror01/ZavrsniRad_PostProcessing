using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[Serializable]
public class Fog : Effect
{
	[Range(0.0f, 1.0f)]
	public float density;
	public Color fogColor;

	[ImageEffectOpaque]
	public override void apply(RenderTexture tex)
	{
		if (mat == null)
		{
			mat = new Material(Shader.Find("Hidden/Fog"));
			mat.hideFlags = HideFlags.HideAndDontSave;
		}

		mat.SetFloat("_Swipe", swipe);
		mat.SetFloat("_Density", density);
		mat.SetColor("_FogColor", fogColor);
		Graphics.Blit(tex, tex, mat);
	}
}
