Shader "Hidden/TESTSHADER" // naziv shadera
{
    // svojstva koja se mogu mijenjati kroz Unity Inspector
    Properties
    {
        // potrebno kako bi shader radio
        // automatski postaje tekstura na koju se primjenjuje efekt
        _MainTex ("Texture", 2D) = "white" {}
    }

    SubShader
    {
        // konfiguracija postavki renderiranja:
        // Cull Off:
        // ne izrezuju se poligoni koji su okrenuti od kamere (ne postoje)
        // ZWrite Off:
        // informacije o dubini se ne zapisuju u spremnik dubine
        // ZTest Always:
        // piksel je uvijek nacrtan, neovisno o udaljenosti od kamere
        Cull Off ZWrite Off ZTest Always

        // dio shadera koji je zajdenjicki svakom prolazu
        CGINCLUDE

        //zadaje da se vertex shader funkcija zove vert
        #pragma vertex vert 
        //zadaje da se fragment shader funkcija zove frag
        #pragma fragment frag

        // koriste se unity funkcije i makro naredbe
        #include "UnityCG.cginc"

        // podatci o svakom vrhu koje dobiva vertex shader
        struct appdata
        {
            float4 vertex : POSITION; // pozicija u prostoru objekta
            float2 uv : TEXCOORD0; // UV koordinate
        };

        // podatci koje vertex shader proslijeduje fragment shaderu
        struct v2f
        {
            float2 uv : TEXCOORD0; // UV koordinate
            // pozicija u prostoru izrezivanja
            float4 vertex : SV_POSITION;
        };

        // vertex shader
        v2f vert (appdata v)
        {
            v2f o;
            // transformira poziciju iz prostora objekta
            // u prostor izrezivanja koristeci makro naredbu
            o.vertex = UnityObjectToClipPos(v.vertex); 
            o.uv = v.uv; // proslijeduje UV koordinate
            return o; //proslijeduje podatke do fragment shadera
        }
        ENDCG

        // prvi prolaz
        Pass
        {
            Name "PrviProlaz" // naziv prolaza

            CGPROGRAM
            //globalna varijabla, moguce ju je zadati u C# kodu
            sampler2D _MainTex;

            //fragment shader
            fixed4 frag (v2f IN) : SV_Target
            {
                // uzorkovanje teksture na dobivenim UV koordinatama
                fixed4 col = tex2D(_MainTex, IN.uv); 
                return col; //fragment shader vraca ocitanu boju
            }
            ENDCG
        }
    }
}
