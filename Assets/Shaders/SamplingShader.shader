Shader "Custom/SamplingShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        ZWrite Off
        Blend off

        // Pass 0: Down Sample
        Pass
        {
            ZTest off
            Cull off

            CGPROGRAM

            #pragma vertex vert_DownSample
            #pragma fragment frag_DownSample

            ENDCG
        }

        // Pass 1: Up Sample
        Pass
        {
            ZTest off
            Cull off

            CGPROGRAM
 
            #pragma vertex vert_UpSample
            #pragma fragment frag_UpSample
 
            ENDCG
        }
    }

    CGINCLUDE

    #include "UnityCG.cginc"

    Texture2D _MainTex;
    uniform half4 _MainTex_TexelSize;
    SamplerState my_point_clamp_sampler, my_linear_clamp_sampler;

    struct VertexInput
    {
        float4 vertex : POSITION;
        half2 texcoord : TEXCOORD0;
    };

    struct VertexOutput_DownSample
    {
        float4 pos : SV_POSITION;
        half2 uv0 : TEXCOORD0;// 右上
        half2 uv1 : TEXCOORD1;// 左下
        half2 uv2 : TEXCOORD2;// 右下
        half2 uv3 : TEXCOORD3;// 左上
    };

    struct VertexOutput_UpSample
    {
        float4 pos : SV_POSITION;
        half2 uv : TEXCOORD0;
    };

    VertexOutput_DownSample vert_DownSample (VertexInput v)
    {
        VertexOutput_DownSample o;
        o.pos = UnityObjectToClipPos(v.vertex);

        o.uv0 = v.texcoord + _MainTex_TexelSize.xy * half2(0.5h, 0.5h);
        o.uv1 = v.texcoord + _MainTex_TexelSize.xy * half2(-0.5h, -0.5h);
        o.uv2 = v.texcoord + _MainTex_TexelSize.xy * half2(0.5h, -0.5h);
        o.uv3 = v.texcoord + _MainTex_TexelSize.xy * half2(-0.5h, 0.5h);

        return o;
    }

    fixed4 frag_DownSample (VertexOutput_DownSample i) : SV_Target
    {
        fixed4 col = (0, 0, 0, 0);

        col += _MainTex.Sample(my_point_clamp_sampler, i.uv0);
        col += _MainTex.Sample(my_point_clamp_sampler, i.uv1);
        col += _MainTex.Sample(my_point_clamp_sampler, i.uv2);
        col += _MainTex.Sample(my_point_clamp_sampler, i.uv3);

        return col / 4;
    }

    VertexOutput_UpSample vert_UpSample (VertexInput v)
    {
        VertexOutput_UpSample o;
        o.pos = UnityObjectToClipPos(v.vertex);
        o.uv = v.texcoord;

        return o;
    }

    fixed4 frag_UpSample (VertexOutput_UpSample i) : SV_Target
    {
        fixed4 col = _MainTex.Sample(my_linear_clamp_sampler, i.uv);

        return col;
    }

    ENDCG

    FallBack off
}
