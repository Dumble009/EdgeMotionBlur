using UnityEngine;

public class MotionBlur : MonoBehaviour
{
    [SerializeField] Material motionBlurMaterial;

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        Graphics.Blit(src, dest, motionBlurMaterial);
    }
}
