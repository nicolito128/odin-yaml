package test_lexer

import lexer "../../lexer"
import vmem "core:mem/virtual"
import "core:testing"
import "core:strings"
import "core:fmt"

@test
test_tokenizer :: proc(t: ^testing.T) {
    arena: vmem.Arena
    defer vmem.arena_free_all(&arena)

	arena_err := vmem.arena_init_growing(&arena)
	ensure(arena_err == nil)

    context.allocator = vmem.arena_allocator(&arena)

    { // Basic document
        data := `
        ---
        key: test
        ...

        `

        tokens, err := lexer.tokenize(data)
        testing.expect_value(t, err, nil)

        success := []lexer.Lexer_Token{
            lexer.Token_Type.Document_Header,
            lexer.Token_Type.Identifier, "key",
            lexer.Token_Type.Whitespace,
            lexer.Token_Type.Literal, "test",
            lexer.Token_Type.Document_Terminator,
            lexer.Token_Type.EOF
        }

        testing.expect(t, len(tokens) == len(success))
        // TODO: check every token
    }
}