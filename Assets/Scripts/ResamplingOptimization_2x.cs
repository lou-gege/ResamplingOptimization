using UnityEngine;

public class ResamplingOptimization_2x : MonoBehaviour
{
    public Texture2D truthTex;

    private Material sampleMaterial;
    private Material gpuDeltaMaterial;
    private Material gpuGatherMaterial;
    private Material gradientMaterial;
    private Material currMaterial;

    private RenderTexture currRT;
    private RenderTexture upSamplingRT;

    private float psnr = 0;
    private float prepsnr = 0;
    private int pixelCount;

    float STEP = 1000f;

    void Start()
    {
        sampleMaterial = new Material(Shader.Find("Custom/SamplingShader"));
        gpuDeltaMaterial = new Material(Shader.Find("Custom/GPUDeltaShader"));
        gpuGatherMaterial = new Material(Shader.Find("Custom/GPUGatherShader"));
        gradientMaterial = new Material(Shader.Find("Custom/GradientShader_2x"));
        currMaterial = GetComponent<Renderer>().material;

        currRT = new RenderTexture(truthTex.width / 2, truthTex.height / 2, 0, RenderTextureFormat.ARGBFloat);
        pixelCount = truthTex.width * truthTex.height;
    }

    void Update()
    {
        // up sampling
        upSamplingRT = new RenderTexture(truthTex.width, truthTex.height, 0, RenderTextureFormat.ARGBFloat);
        Graphics.Blit(currRT, upSamplingRT, sampleMaterial, 1);

        // calculate mse psnr
        float mse = CalculateMSE_GPU_Gather();
        //float mse = CalculateMSE_CPU();
        prepsnr = psnr;
        UpdatePSNR(mse);
        Debug.Log("psnr: " + psnr);

        if (psnr < prepsnr)
        {
            STEP *= 0.8f;
        }

        // calculate gradient and update texture
        float gradientPart = 2f / (3 * pixelCount) * STEP;
        gradientMaterial.SetTexture("_TruthTex", truthTex);
        gradientMaterial.SetTexture("_UpSamplingTex", upSamplingRT);
        gradientMaterial.SetFloat("_GradientPart", gradientPart);

        RenderTexture newRT = new RenderTexture(currRT.width, currRT.height, 0, RenderTextureFormat.ARGBFloat);
        Graphics.Blit(currRT, newRT, gradientMaterial);

        RenderTexture temp = currRT;
        currRT = newRT;
        Destroy(temp);
        Destroy(upSamplingRT);

        currMaterial.SetTexture("_MainTex", currRT);
    }

    float CalculateMSE_CPU()
    {
        RenderTexture.active = upSamplingRT;
        Texture2D currTex = new Texture2D(upSamplingRT.width, upSamplingRT.height, TextureFormat.RFloat, false);
        currTex.ReadPixels(new Rect(0, 0, upSamplingRT.width, upSamplingRT.height), 0, 0);
        currTex.Apply();

        Color[] currTexPixels = currTex.GetPixels();
        Color[] truthTexPixels = truthTex.GetPixels();

        float sumSquaredDiff = 0f;
        int pixelCount = currTexPixels.Length;

        for (int i = 0; i < pixelCount; i++)
        {
            sumSquaredDiff += Mathf.Pow(currTexPixels[i].r - truthTexPixels[i].r, 2)
                            + Mathf.Pow(currTexPixels[i].g - truthTexPixels[i].g, 2)
                            + Mathf.Pow(currTexPixels[i].b - truthTexPixels[i].b, 2);
        }

        float mse = sumSquaredDiff / (pixelCount * 3);

        return mse;
    }

    float CalculateMSE_GPU_Gather()
    {
        RenderTexture deltaRenderTexture = new RenderTexture(truthTex.width, truthTex.height, 0, RenderTextureFormat.RFloat);
        deltaRenderTexture.enableRandomWrite = true;
        deltaRenderTexture.Create();

        gpuDeltaMaterial.SetTexture("_ResultTex", upSamplingRT);
        Graphics.Blit(truthTex, deltaRenderTexture, gpuDeltaMaterial);

        int maxLevel = (int)Mathf.Log(Mathf.Max(deltaRenderTexture.width, deltaRenderTexture.height), 2);
        RenderTexture srcTempRT = deltaRenderTexture;
        for (int i = 0; i < maxLevel; i++)
        {
            RenderTexture destTempRT = new RenderTexture(srcTempRT.width / 2, srcTempRT.height / 2, 0, RenderTextureFormat.RFloat);
            Graphics.Blit(srcTempRT, destTempRT, gpuGatherMaterial);
            RenderTexture temp = srcTempRT;
            srcTempRT = destTempRT;
            Destroy(temp);
        }

        RenderTexture.active = srcTempRT;
        Texture2D resultTexture = new Texture2D(srcTempRT.width, srcTempRT.height, TextureFormat.RFloat, false);
        resultTexture.ReadPixels(new Rect(0, 0, srcTempRT.width, srcTempRT.height), 0, 0);
        resultTexture.Apply();

        Color[] texPixels = resultTexture.GetPixels();

        RenderTexture.active = null;
        Destroy(srcTempRT);
        Destroy(resultTexture);

        return texPixels[0].r / (3 * pixelCount);
    }

    void UpdatePSNR(float mse)
    {
        //Debug.Log("mse: " + mse);
        psnr = 10 * Mathf.Log10(1f / mse);
    }
}
