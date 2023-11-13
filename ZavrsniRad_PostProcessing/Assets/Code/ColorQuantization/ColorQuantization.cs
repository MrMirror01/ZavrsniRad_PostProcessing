using System;
using System.Collections;
using System.Collections.Generic;
using System.Diagnostics.Contracts;
using UnityEngine;

[Serializable]
public class ColorQuantization : Effect
{
	[Range(0.0f, 1.0f)]
	public float spread;
	[Range(1, 256)]
	public int numberOfColors;
	public bool usePalette;
	public Texture2D palette;
	public override void apply(RenderTexture tex)
	{
		if (mat == null)
		{
			mat = new Material(Shader.Find("Hidden/ColorQuantization"));
			mat.hideFlags = HideFlags.HideAndDontSave;
		}
		mat.SetFloat("_Swipe", swipe);
		mat.SetFloat("_Spread", spread);
		mat.SetInt("_NumberOfColors", numberOfColors);

		if (!usePalette)
			Graphics.Blit(tex, tex, mat, 0);
		else
		{
			mat.SetTexture("_Palette", palette);
			Graphics.Blit(tex, tex, mat, 1);
		}
	}
}
