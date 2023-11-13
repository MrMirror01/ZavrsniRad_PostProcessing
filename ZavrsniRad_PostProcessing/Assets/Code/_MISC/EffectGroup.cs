using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "NewEffectGroup", menuName = "Effect Group")]
public class EffectGroup : ScriptableObject
{
    public enum EffectType
    {
		AdvancedColorCorrection = 0,
		Bloom = 1,
	}
	public static readonly Type[] effectTypes = new Type[2] {
		typeof(AdvancedColorCorrection),
		typeof(Bloom),
	};

    public EffectType addedEffect;

    public List<Effect> effects = new List<Effect>();
}
