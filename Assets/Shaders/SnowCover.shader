Shader "Custom/SnowCover"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _NormalTex ("Normal", 2D) = "white" {}
        _OcclusionTex ("Occlusion", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0

        [Toggle(SNOW_ON)] 
        _SnowOn("Use snow?", Int) = 0
        _SnowColor("Snow Color", Color) = (1,1,1,1)
        _SnowTex("Snow", 2D) = "white" {}
        _SnowAmount ("Snow Amount", Range(0,1)) = 0.1
        _SnowDirection ("Snow Direction", Vector) = (0,1,0,0)
        _SnowHeightTex("Snow Height", 2D) = "white" {}
        _SnowRoughnessTex("Snow Roughness", 2D) = "white" {}
        _SnowGlossiness("Snow Glossiness", Range(0,1)) = 0.5
        _SnowEmissionColor("Snow Emission Color", Color) = (1,1,1,1)
        _SnowEmissionAmount("Snow Emission Value", Range(0,1)) = 0.1
        _Blend("Texture Blend", Range(0,1)) = 0.0
        
        
        [Toggle(DISPLACE_ON)]
        _DisplaceOn("Displace vertices to give height to snow?", Int) = 0
        _DisplaceAmount("Displacement amount", Range(0,0.5)) = 0.2
        _SnowExpansion("Snow Expansion", Range(-1, 1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows vertex:vert

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0
        #pragma shader_feature SNOW_ON
        #pragma shader_feature DISPLACE_ON

        sampler2D _MainTex;
        sampler2D _NormalTex;
        sampler2D _MetallicTex;
        sampler2D _OcclusionTex;
        sampler2D _SnowTex;
        sampler2D _SnowHeightTex;
        sampler2D _SnowRoughnessTex;

        struct Input
        {
            float2 uv_MainTex : TEXCOORD0;
            float3 worldNormal;
            float4 screenPos;
            INTERNAL_DATA
        };

        half _Glossiness;
        half _SnowGlossiness;
        fixed4 _Color;
        fixed4 _SnowColor;
        float _SnowAmount;
        float4 _SnowDirection;
        float _SnowExpansion;
        float _SnowDepth;
        float _DisplaceAmount;
        half _Blend;

        fixed4 _SnowEmissionColor;
        float _SnowEmissionAmount;

        float rand(float2 co) {
            return frac(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453);
        }

        void vert(inout appdata_full v)
        {                      
            // Convert the snow direction to object coordinates
            float3 snowDirNormalized = normalize(mul(unity_WorldToObject, float4(_SnowDirection.xyz, 0))).xyz;

            // signifies how close we are aligned with the desired snow direction
            float snowFitness = dot(v.normal, snowDirNormalized);

            // we don't want to use branching logic (ifs etc.) in shaders if we can help it
            // but comparison and multiplication is fairly cheap!
            // so instead of that we create a factor and use that
            float displacementAmount = snowFitness > _SnowAmount;

            #ifndef DISPLACE_ON
            displacementAmount = 0;
            #endif

            // we offset the direction somewhat to create a more natural looking snow
            float3 vertOffset = snowDirNormalized + lerp(-v.normal, v.normal, (_SnowExpansion + 1) / 2);
            vertOffset = normalize(vertOffset);

            // and then move the vertices up by the specified amount
            float snowFactor = lerp(0, _DisplaceAmount, snowFitness * snowFitness * snowFitness);
            v.vertex.xyz += vertOffset * snowFactor * displacementAmount;
        }

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed3 texNormal = UnpackNormal(tex2D(_NormalTex, IN.uv_MainTex));
            o.Normal = texNormal.rgb;
            float3 worldNormal = WorldNormalVector(IN, o.Normal);

            float snowFitness = (dot(worldNormal, _SnowDirection) + 1) / 2;           
            // switch around for comparison
            snowFitness = 1 - snowFitness;

            float snowStrength = snowFitness < _SnowAmount;

            fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
            fixed4 snowColor = tex2D(_SnowTex, IN.uv_MainTex) * _SnowColor;

            #ifndef SNOW_ON
            snowStrength = 0;
            #endif

            fixed4 metallic = tex2D(_MetallicTex, IN.uv_MainTex);
            fixed4 occlusion = tex2D(_OcclusionTex, IN.uv_MainTex);

            o.Albedo = c * (1 - snowStrength) + snowColor * lerp(-snowStrength, snowStrength, 1 - snowFitness);
            o.Metallic = metallic.r;
            o.Occlusion = occlusion.r;
            o.Smoothness = _Glossiness * (1 - snowStrength) + _SnowGlossiness * snowStrength;
            o.Emission = _SnowEmissionColor * _SnowEmissionAmount * snowStrength;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
    //CustomEditor "SnowCoverShaderGUI"
}
