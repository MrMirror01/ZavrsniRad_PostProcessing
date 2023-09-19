using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PostProcessingDriver : MonoBehaviour
{
    public BlurParameters blur;
	[Space(10)]
    public SharpenParameters sharpen;

	private void OnRenderImage(RenderTexture source, RenderTexture destination)
	{
		if (blur.active) Blur.applyEffect(source, blur);
		if (sharpen.active) Sharpen.applyEffect(source, sharpen);

		Graphics.Blit(source, destination);
	}
}
