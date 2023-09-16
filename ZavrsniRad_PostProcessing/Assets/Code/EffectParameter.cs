using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor.EditorTools;
using UnityEngine;

[Serializable]
public abstract class EffectParameter
{
    public bool active = true;
    [Range(0f, 1f)]
    public float swipe = 1f;
}
