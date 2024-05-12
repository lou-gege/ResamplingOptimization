using UnityEngine;

public class DownSampling_campare : MonoBehaviour
{
    public Texture2D originTexture;

    private RenderTexture downSampledRenderTexture;
    private Material currMaterial;

    void Start()
    {
        Material samplingMaterial = new Material(Shader.Find("Custom/SamplingShader"));

        downSampledRenderTexture = new RenderTexture(originTexture.width / 2, originTexture.height / 2, 0);
        downSampledRenderTexture.filterMode = FilterMode.Bilinear;
        downSampledRenderTexture.Create();

        Graphics.Blit(originTexture, downSampledRenderTexture, samplingMaterial, 0);

        currMaterial = GetComponent<Renderer>().material;
        currMaterial.SetTexture("_MainTex", downSampledRenderTexture);
    }
}
