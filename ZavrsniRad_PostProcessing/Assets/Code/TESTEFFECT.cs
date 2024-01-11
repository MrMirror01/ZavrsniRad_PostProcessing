using System;
using UnityEngine;

[Serializable] // oznacava da se objekt moze prikazati u inspektoru
public class TESTEFFECT : Effect
{
	// metoda za primjenjivanje efekta
	public override void apply(RenderTexture tex)
	{
		// na pocetku materijal jos nije definiran
		// pa ga je potrebno inicijalizirati
		if (mat == null)
		{
			// napravimo materijal koristeci shader
			// koji se referencira koristeci naziv
			Shader shader = Shader.Find("Hidden/TESTSHADER");
			mat = new Material(shader);
			mat.hideFlags = HideFlags.HideAndDontSave;
		}
		// zadaju se parametri shadera
		mat.SetFloat("_Swipe", swipe);

		// shader se primjenjuje na teksturu
		Graphics.Blit(tex, tex, mat);
	}
}
