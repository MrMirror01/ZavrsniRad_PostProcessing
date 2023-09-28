using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Tonemapping : Effect
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

		Graphics.Blit(tex, tex, mat);
	}
}
