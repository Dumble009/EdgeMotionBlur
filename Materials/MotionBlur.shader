Shader "Hidden/MotionBlur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BlurSize ("Blur Size", Float) = 0
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            // 画面のアスペクト比の計算
            // 参考 : https://qiita.com/Santarh/items/428d2e0f33852e6f37b5
            float getAspect()
            {
                float4 projectionSpaceUpperRight = float4(1, 1, UNITY_NEAR_CLIP_VALUE, _ProjectionParams.y);
                float4 viewSpaceUpperRight = mul(unity_CameraInvProjection, projectionSpaceUpperRight);
                float aspect = viewSpaceUpperRight.x / viewSpaceUpperRight.y;

                return aspect;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            half _BlurSize;

            static const int BLUR_SAMPLE_COUNT = 8;

            fixed4 frag (v2f i) : SV_Target
            {
                float aspect = getAspect();
                float2 scale = _BlurSize / 1000;
                fixed4 col = tex2D(_MainTex, i.uv);
                
                return col;
            }
            ENDCG
        }
    }
}
