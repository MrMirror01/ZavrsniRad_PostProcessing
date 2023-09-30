using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[Serializable]
public class Sharpen : Effect
{
	public override void apply(RenderTexture tex)
	{
		if (mat == null)
		{
			mat = new Material(Shader.Find("Hidden/Sharpen"));
			mat.hideFlags = HideFlags.HideAndDontSave;
		}
		mat.SetFloat("_Swipe", swipe);

		Graphics.Blit(tex, tex, mat);
	}
}
