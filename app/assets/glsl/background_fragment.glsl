out vec4 outColor;
uniform vec2 uResolution;
uniform float uPositionOffset;
uniform vec4 uBlendColor;
uniform float uTime;

void main() {
  float u_zoom = 50.0; // Grid density/scale
  float u_radius = 0.15; // Dot size
  float positionOffsetProjection = 0.0005;
  float blink = sin((uTime / 1000.0) * 7.0);
  gln_tFBMOpts opts = gln_tFBMOpts(0.9, 0.2, 1.5, 2.0, 0.7 + (blink * 0.25), 5, false, false);

  vec4 fromColor = vec4(0.01);

  vec2 st = gl_FragCoord.xy / uResolution;

  // Normalize UVs based on screen aspect ratio
  vec2 uv = gl_FragCoord.xy / uResolution.xy;
  uv.x *= uResolution.x / uResolution.y;

  // get noise
  float n = gln_sfbm(vec2(st.x + (uPositionOffset * positionOffsetProjection), st.y), opts);

  // Scale space and get local cell coordinates (-0.5 to 0.5)
  vec2 grid = fract(uv * u_zoom) - 0.5;

  // Distance from center of the cell
  float dist = length(grid);

  // Smooth circle edge
  float dot = smoothstep(u_radius, u_radius - 0.05, dist);

  vec4 color = (uBlendColor * n) + (fromColor * (1.0 - n));

  outColor = vec4(vec4(dot) * color);
}
