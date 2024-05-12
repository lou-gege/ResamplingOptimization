Shader "Custom/GPUDeltaShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ResultTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        ZWrite Off
        Blend off

        Pass
        {
            ZTest off
            Cull off

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            ENDCG
        }
    }

    CGINCLUDE

    #include "UnityCG.cginc"

    sampler2D _MainTex, _ResultTex;

    struct VertexInput
    {
        float4 vertex : POSITION;
        half2 texcoord : TEXCOORD0;
    };

    struct VertexOutput
    {
        float4 pos : SV_POSITION;
        half2 uv : TEXCOORD0;
    };

    VertexOutput vert (VertexInput v)
    {
        VertexOutput o;
        o.pos = UnityObjectToClipPos(v.vertex);
        o.uv = v.texcoord;

        return o;
    }

    float frag (VertexOutput i) : SV_Target
    {
        float4 originCol = tex2D(_MainTex, i.uv);
        float4 resultCol = tex2D(_ResultTex, i.uv);

        float deltaR = pow((originCol.r - resultCol.r), 2);
        float deltaG = pow((originCol.g - resultCol.g), 2);
        float deltaB = pow((originCol.b - resultCol.b), 2);

        return deltaR + deltaG + deltaB;
    }

    ENDCG

    FallBack off
}
