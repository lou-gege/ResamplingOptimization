Shader "Custom/SimpleTextureShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            ENDCG
        }
    }

    CGINCLUDE

    #include "UnityCG.cginc"

    Texture2D _MainTex;
    SamplerState my_linear_clamp_sampler, my_point_clamp_sampler;

    struct VertexInput
    {
        float4 vertex : POSITION;
        float2 texcoord : TEXCOORD0;
    };

    struct VertexOutput
    {
        float4 pos : SV_POSITION;
        float2 uv : TEXCOORD0;
    };

    VertexOutput vert (VertexInput v)
    {
        VertexOutput o;
        o.pos = UnityObjectToClipPos(v.vertex);
        o.uv = v.texcoord;

        return o;
    }

    float4 frag (VertexOutput i) : SV_Target
    {
        return _MainTex.Sample(my_point_clamp_sampler, i.uv);
    }

    ENDCG

    FallBack off
}
