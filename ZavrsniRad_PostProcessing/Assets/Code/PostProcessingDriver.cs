using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PostProcessingDriver : MonoBehaviour
{
    public BlurParameters blur;

	private void OnRenderImage(RenderTexture source, RenderTexture destination)
	{
		//RenderTexture intermediete = RenderTexture.GetTemporary(source.descriptor);
		//Graphics.Blit(source, new Material(blur.shader));

		if (blur.active) Blur.ApplyEffect(source, blur);

		Graphics.Blit(source, destination);
		//RenderTexture.ReleaseTemporary(intermediete);
	}
}
