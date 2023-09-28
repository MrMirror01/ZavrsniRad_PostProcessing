using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[Serializable]
public class ToneMapping : Effect
{
	[Range(1, 10)]
	public float whitePoint = 1.0f;

	public override void apply(RenderTexture tex)
	{
		if (mat == null)
		{
			mat = new Material(shader);
			mat.hideFlags = HideFlags.HideAndDontSave;
		}
		mat.SetFloat("_Swipe", swipe);
		mat.SetFloat("_WhitePoint", whitePoint);

		Graphics.Blit(tex, tex, mat);
	}
}
