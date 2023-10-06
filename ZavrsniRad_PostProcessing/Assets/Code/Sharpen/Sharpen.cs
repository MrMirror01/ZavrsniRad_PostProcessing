using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[Serializable]
public class Sharpen : Effect
{
	public enum SharpnessType
	{
		BoxSharpen = 0,
		AdaptiveSharpness = 1
	}

	public SharpnessType type;
	[Range(0, 1)]
	public float sharpnessStrength;

	public override void apply(RenderTexture tex)
	{
		if (mat == null)
		{
			mat = new Material(Shader.Find("Hidden/Sharpen"));
			mat.hideFlags = HideFlags.HideAndDontSave;
		}
		mat.SetFloat("_Swipe", swipe);
		mat.SetFloat("_SharpnessStrength", sharpnessStrength);

		Graphics.Blit(tex, tex, mat, (int)type);
	}
}
