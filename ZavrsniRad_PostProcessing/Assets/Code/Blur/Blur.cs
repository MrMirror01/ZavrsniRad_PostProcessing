using System;
using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.UI;

public static class Blur
{
	public static RenderTexture applyEffect(RenderTexture tex, BlurParameters parameters)
	{
		Material mat = new Material(parameters.shader);
		mat.SetFloat("_Swipe", parameters.swipe);

		for (int i = 0; i < parameters.iterations; i++)
		{
			Graphics.Blit(tex, tex, mat, (int)parameters.type);
			if (parameters.type == BlurParameters.BlurType.OptimisedGaussianBlur)
				Graphics.Blit(tex, tex, mat, (int)parameters.type + 1); //drugi pass
		}
		
		return tex;
	}
}
