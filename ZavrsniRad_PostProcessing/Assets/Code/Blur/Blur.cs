using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public static class Blur
{
	public static RenderTexture ApplyEffect(RenderTexture tex, BlurParameters parameters)
	{
		Material mat = new Material(parameters.shader);
		mat.SetFloat("_Swipe", parameters.swipe);

		Graphics.Blit(tex, tex, mat);
		return tex;
	}
}
