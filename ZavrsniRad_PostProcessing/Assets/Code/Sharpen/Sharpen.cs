using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Sharpen
{
	public static RenderTexture applyEffect(RenderTexture tex, SharpenParameters parameters)
	{
		Material mat = new Material(parameters.shader);
		mat.SetFloat("_Swipe", parameters.swipe);

		for (int i = 0; i < parameters.iterations; i++)
		{
			Graphics.Blit(tex, tex, mat);
		}

		return tex;
	}
}
