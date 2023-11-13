using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor.EditorTools;
using UnityEditor.Timeline.Actions;
using UnityEngine;

[Serializable]
public abstract class Effect
{
    public bool active = false;
    [Range(0f, 1f)]
    public float swipe = 1f;

    protected Material mat;

    public abstract void apply(RenderTexture tex);
}
