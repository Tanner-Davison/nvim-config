;extends

; Injects GLSL/HLSL/Slang highlighting into C++ raw string literals
; (R"( ... )") tagged with a leading `// glsl`, `// hlsl`, or `// slang`
; comment as the first line of content, e.g.:
;
;   const char* codeVS = R"(
;   // glsl
;   layout (location=0) out vec3 dir;
;   ...
;   )";
;
; tree-sitter-cpp's raw string grammar has changed across versions:
;   (A) older/some builds: raw_string_literal is a single opaque
;       external-scanner token with no children -- the whole node's text
;       includes the R"( / )" delimiters, so we trim them with #offset!.
;   (B) newer builds: raw_string_literal wraps a named raw_string_content
;       child whose text already excludes the delimiters -- no offset
;       needed, match directly against the start of the content.
; Both pattern sets are included below; whichever matches your installed
; grammar will fire, the other simply never matches.

; --- (A) whole-token raw_string_literal, delimiters included ---

((raw_string_literal) @injection.content
  (#lua-match? @injection.content "^R\"%(%s*//%s*glsl")
  (#offset! @injection.content 0 3 0 -2)
  (#set! injection.language "glsl"))

((raw_string_literal) @injection.content
  (#lua-match? @injection.content "^R\"%(%s*//%s*hlsl")
  (#offset! @injection.content 0 3 0 -2)
  (#set! injection.language "hlsl"))

((raw_string_literal) @injection.content
  (#lua-match? @injection.content "^R\"%(%s*//%s*slang")
  (#offset! @injection.content 0 3 0 -2)
  (#set! injection.language "slang"))

; --- (B) raw_string_content child, delimiters excluded ---

(raw_string_literal
  (raw_string_content) @injection.content
  (#lua-match? @injection.content "^%s*//%s*glsl")
  (#set! injection.language "glsl"))

(raw_string_literal
  (raw_string_content) @injection.content
  (#lua-match? @injection.content "^%s*//%s*hlsl")
  (#set! injection.language "hlsl"))

(raw_string_literal
  (raw_string_content) @injection.content
  (#lua-match? @injection.content "^%s*//%s*slang")
  (#set! injection.language "slang"))
