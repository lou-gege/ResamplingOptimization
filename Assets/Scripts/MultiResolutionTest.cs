using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;

public class MultiResolutionTest : MonoBehaviour
{
    public Texture2D truthTex;
    public Vector2 resolution;

    private Material sampleMaterial;
    private Material gpuDeltaMaterial;
    private Material gpuGatherMaterial;
    private Material gradientMaterial;

    //private RenderTexture currRT;
    private RenderTexture upSamplingRT;

    private float psnr = -100f;
    private float prepsnr = 0f;
    private int pixelCount;
    private float STEP = 1000f;

    private readonly float epsilon = 0.0001f;

    private RenderTexture optiRes;
    private RenderTexture dsRes;

    void Start()
    {
        optiRes = GenOptiRes();
        dsRes = GenDSRes();
    }

    [ContextMenu("Run")]
    void Run()
    {
        RunCore(resolution);
    }

    [ContextMenu("RunAll")]
    void RunAll()
    {
        for (int x = 1; x < 2049; x *= 2)
        {
            for (int y = 1; y < 2049; y *= 2)
            {
                RunCore(new Vector2(x, y));
            }
        }
    }

    [ContextMenu("SaveToCSV")]
    void SaveToCSV()
    {
        string projectPath = Application.dataPath;
        string filePath = Path.Combine(projectPath, "MultiResolutionTest.csv");

        StreamWriter streamWriter = new StreamWriter(filePath);

        for (int x = 1; x < 2049; x *= 2)
        {
            for (int y = 1; y < 2049; y *= 2)
            {

                // true tex sample
                var trueTexSamplingRT = new RenderTexture(x, y, 0, RenderTextureFormat.ARGBFloat);
                Graphics.Blit(truthTex, trueTexSamplingRT, sampleMaterial, 1);

                // opti tex sample
                var optiTexSamplingRT = new RenderTexture(x, y, 0, RenderTextureFormat.ARGBFloat);
                Graphics.Blit(optiRes, optiTexSamplingRT, sampleMaterial, 1);

                // downsample tex sample
                var dsTexSamplingRT = new RenderTexture(x, y, 0, RenderTextureFormat.ARGBFloat);
                Graphics.Blit(dsRes, dsTexSamplingRT, sampleMaterial, 1);

                float psnr_opti = CalculatePSNRByMSE(CalculateMSE_GPU_Delta(trueTexSamplingRT, optiTexSamplingRT));
                float psnr_ds = CalculatePSNRByMSE(CalculateMSE_GPU_Delta(trueTexSamplingRT, dsTexSamplingRT));

                //if (psnr_opti < psnr_ds)
                {
                    streamWriter.WriteLine($"{x}*{y}" + "," + psnr_opti + "," + psnr_ds);
                }
            }
        }

        streamWriter.Close();
        Debug.Log("Save csv finished. ");
    }

    void RunCore(Vector2 resolution)
    {
        // true tex sample
        var trueTexSamplingRT = new RenderTexture((int)resolution.x, (int)resolution.y, 0, RenderTextureFormat.ARGBFloat);
        Graphics.Blit(truthTex, trueTexSamplingRT, sampleMaterial, 1);

        // opti tex sample
        var optiTexSamplingRT = new RenderTexture((int)resolution.x, (int)resolution.y, 0, RenderTextureFormat.ARGBFloat);
        Graphics.Blit(optiRes, optiTexSamplingRT, sampleMaterial, 1);

        // downsample tex sample
        var dsTexSamplingRT = new RenderTexture((int)resolution.x, (int)resolution.y, 0, RenderTextureFormat.ARGBFloat);
        Graphics.Blit(dsRes, dsTexSamplingRT, sampleMaterial, 1);

        float psnr_opti = CalculatePSNRByMSE(CalculateMSE_GPU_Delta(trueTexSamplingRT, optiTexSamplingRT));
        float psnr_ds = CalculatePSNRByMSE(CalculateMSE_GPU_Delta(trueTexSamplingRT, dsTexSamplingRT));

        if (psnr_opti < psnr_ds)
        {
            Debug.Log($"{(int)resolution.x}*{(int)resolution.y}: opti: {psnr_opti}, ds: {psnr_ds}");
        }
    }

    RenderTexture GenOptiRes()
    {
        sampleMaterial = new Material(Shader.Find("Custom/SamplingShader"));
        gpuDeltaMaterial = new Material(Shader.Find("Custom/GPUDeltaShader"));
        gpuGatherMaterial = new Material(Shader.Find("Custom/GPUGatherShader"));
        gradientMaterial = new Material(Shader.Find("Custom/GradientShader_2x"));

        var currRT = new RenderTexture(truthTex.width / 2, truthTex.height / 2, 0, RenderTextureFormat.ARGBFloat);
        pixelCount = truthTex.width * truthTex.height;

        while (Mathf.Abs(psnr - prepsnr) > epsilon)
        {
            // up sampling
            upSamplingRT = new RenderTexture(truthTex.width, truthTex.height, 0, RenderTextureFormat.ARGBFloat);
            Graphics.Blit(currRT, upSamplingRT, sampleMaterial, 1);

            // calculate mse psnr
            float mse = CalculateMSE_GPU_Gather(truthTex, upSamplingRT);
            //float mse = CalculateMSE_CPU();
            prepsnr = psnr;
            psnr = CalculatePSNRByMSE(mse);
            //Debug.Log("psnr: " + psnr);

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
        }

        Debug.Log($"Opti result generated. psnr: {psnr}");
        return currRT;
    }

    RenderTexture GenDSRes()
    {
        Material samplingMaterial = new Material(Shader.Find("Custom/SamplingShader"));

        var downSampledRenderTexture = new RenderTexture(truthTex.width / 2, truthTex.height / 2, 0);
        downSampledRenderTexture.filterMode = FilterMode.Bilinear;
        downSampledRenderTexture.Create();

        Graphics.Blit(truthTex, downSampledRenderTexture, samplingMaterial, 0);

        return downSampledRenderTexture;
    }

    float CalculateMSE_GPU_Gather(Texture tex1, Texture tex2)
    {
        RenderTexture deltaRenderTexture = new RenderTexture(tex1.width, tex1.height, 0, RenderTextureFormat.RFloat);
        deltaRenderTexture.enableRandomWrite = true;
        deltaRenderTexture.Create();

        gpuDeltaMaterial.SetTexture("_ResultTex", tex2);
        Graphics.Blit(tex1, deltaRenderTexture, gpuDeltaMaterial);

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

        return texPixels[0].r / (3 * tex1.width * tex1.height);
    }

    float CalculateMSE_GPU_Delta(Texture tex1, Texture tex2)
    {
        float mse = 0f;

        var deltaRenderTexture = new RenderTexture(tex1.width, tex1.height, 0, RenderTextureFormat.RFloat);
        deltaRenderTexture.enableRandomWrite = true;
        deltaRenderTexture.Create();

        gpuDeltaMaterial.SetTexture("_ResultTex", tex2);
        Graphics.Blit(tex1, deltaRenderTexture, gpuDeltaMaterial);

        // ¶ÁÈ¡deltaÊý¾Ý
        RenderTexture.active = deltaRenderTexture;
        Texture2D deltaTexture = new Texture2D(deltaRenderTexture.width, deltaRenderTexture.height, TextureFormat.RFloat, false);
        deltaTexture.ReadPixels(new Rect(0, 0, deltaRenderTexture.width, deltaRenderTexture.height), 0, 0);
        deltaTexture.Apply();

        Color[] texPixels = deltaTexture.GetPixels();

        foreach (Color c in texPixels)
        {
            mse += c.r;
        }

        Destroy(deltaTexture);
        return mse / (texPixels.Length * 3);
    }

    float CalculatePSNRByMSE(float mse)
    {
        return 10 * Mathf.Log10(1f / mse);
    }
}
