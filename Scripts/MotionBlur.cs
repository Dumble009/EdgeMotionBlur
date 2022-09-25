using UnityEngine;

public class MotionBlur : MonoBehaviour
{
    [SerializeField] Material motionBlurMaterial;
    [SerializeField] float speed;

    private void Update()
    {
        // 十字キーの上下 or W,Sキーで前後に移動する処理
        float vertical = Input.GetAxis("Vertical");
        transform.position += Vector3.forward * vertical * speed * Time.deltaTime;

        motionBlurMaterial.SetFloat("_SpeedCoeff", Mathf.Abs(vertical));
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        Graphics.Blit(src, dest, motionBlurMaterial);
    }
}
