using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Test : MonoBehaviour
{
    public Texture2D truthTex;

    public Camera viewCamera;
    public GameObject modelQuad;

    private Material texMaterial;
    private Material uvMaterial;

    private RenderTexture textureRT;
    private RenderTexture uvRT;
    private Material currMaterial;
    //private Material modelQuadMaterial;

    // Start is called before the first frame update
    void Start()
    {
        textureRT = new RenderTexture(512, 512, 0);
        uvRT = new RenderTexture(32, 32, 0, RenderTextureFormat.RGFloat);
        currMaterial = GetComponent<Renderer>().material;
        //modelQuadMaterial = modelQuad.GetComponent<Renderer>().material;

        texMaterial = modelQuad.GetComponent<Renderer>().material;
        uvMaterial = new Material(Shader.Find("Custom/UVShader"));
    }

    // Update is called once per frame
    void Update()
    {
        viewCamera.targetTexture = textureRT;
        modelQuad.GetComponent<Renderer>().material = texMaterial;
        viewCamera.Render();

        viewCamera.targetTexture = uvRT;
        uvMaterial.SetTexture("_MainTex", truthTex);
        modelQuad.GetComponent<Renderer>().material = uvMaterial;
        viewCamera.Render();

        currMaterial.SetTexture("_MainTex", uvRT);
    }
}
