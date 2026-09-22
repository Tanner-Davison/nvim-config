-- DISABLED — this plugin's built-in templates only cover Rust, Python,
-- TypeScript, and JavaScript as *host* languages; it has no C/C++ template,
-- and its setup() schema doesn't accept a flat {lang = target} map (that was
-- my mistake in the original config here). Real GLSL/HLSL/Slang injection
-- for embedded C++ raw-string shaders is now handled directly via
-- ~/.config/nvim/after/queries/cpp/injections.scm instead, using tree-sitter's
-- native #offset! directive to strip the R"( / )" delimiters. Left here
-- disabled rather than deleted, since this tool can't delete files on your
-- machine -- feel free to `rm` this file entirely.
return {
	"DariusCorvus/tree-sitter-language-injection.nvim",
	enabled = false,
}
