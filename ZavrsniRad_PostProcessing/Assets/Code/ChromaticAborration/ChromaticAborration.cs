using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[Serializable]
public class ChromaticAborration : Effect
{
	public Vector2 offsetDirection;
	[Range(0f, 0.1f)]
	public float offsetAmount;

	public override void apply(RenderTexture tex)
	{
		if (mat == null)
		{
			mat = new Material(shader);
			mat.hideFlags = HideFlags.HideAndDontSave;
		}
		mat.SetFloat("_Swipe", swipe);
		mat.SetVector("_OffsetDirection", offsetDirection);
		mat.SetFloat("_OffsetAmount", offsetAmount);

		Graphics.Blit(tex, tex, mat);
	}
}
