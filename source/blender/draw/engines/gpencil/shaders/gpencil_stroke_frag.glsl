uniform int color_type;
uniform sampler2D myTexture;

uniform float gradient_f;

uniform vec4 colormix;
uniform float mix_stroke_factor;

in vec4 mColor;
in vec2 mTexCoord;
in vec2 uvfac;

out vec4 fragColor;

#define texture2D texture

/* keep this list synchronized with list in gpencil_engine.h */
#define GPENCIL_COLOR_SOLID 0
#define GPENCIL_COLOR_TEXTURE 1
#define GPENCIL_COLOR_PATTERN 2

#define ENDCAP 1.0

void main()
{

  vec4 tColor = vec4(mColor);
  /* if uvfac[1]  == 1, then encap */
  if (uvfac[1] == ENDCAP) {
    vec2 center = vec2(uvfac[0], 0.5);
    float dist = length(mTexCoord - center);
    if (dist > 0.50) {
      discard;
    }
  }
  /* Solid */
  if (color_type == GPENCIL_COLOR_SOLID) {
    fragColor = tColor;
  }

  /* texture for endcaps */
  vec4 text_color;
  if (uvfac[1] == ENDCAP) {
    text_color = texture2D(myTexture, vec2(mTexCoord.x, mTexCoord.y));
  }
  else {
    text_color = texture2D(myTexture, mTexCoord);
  }

  /* texture */
  if (color_type == GPENCIL_COLOR_TEXTURE) {
    if (mix_stroke_factor > 0.0) {
      fragColor.rgb = mix(text_color.rgb, colormix.rgb, mix_stroke_factor);
      fragColor.a = text_color.a;
    }
    else {
      fragColor = text_color;
    }

    /* mult both alpha factor to use strength factor */
    fragColor.a = min(fragColor.a * tColor.a, fragColor.a);
  }
  /* pattern */
  if (color_type == GPENCIL_COLOR_PATTERN) {
    fragColor = tColor;
    /* mult both alpha factor to use strength factor with color alpha limit */
    fragColor.a = min(text_color.a * tColor.a, tColor.a);
  }

  /* gradient */
  /* keep this disabled while the line glitch bug exists
  if (gradient_f < 1.0) {
    float d = abs(mTexCoord.y - 0.5)  * (1.1 - gradient_f);
    float alpha = 1.0 - clamp((fragColor.a - (d * 2.0)), 0.03, 1.0);
    fragColor.a = smoothstep(fragColor.a, 0.0, alpha);
    
  }
  */

  if (fragColor.a < 0.0035)
    discard;
}
