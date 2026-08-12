in vec2 aVertexPosition;

void main() {
    // Z ekseni 0, W ise 1 olarak doğrudan atanır
  gl_Position = vec4(aVertexPosition, 0.0, 1.0);
}