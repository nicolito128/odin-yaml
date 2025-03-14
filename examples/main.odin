package test_lexer

import lexer "../lexer"
import vmem "core:mem/virtual"
import "core:fmt"
import "core:strings"

main :: proc() {
    arena: vmem.Arena
    defer vmem.arena_free_all(&arena)

	arena_err := vmem.arena_init_growing(&arena)
	ensure(arena_err == nil)

    context.allocator = vmem.arena_allocator(&arena)

    data := lexer.read_file("./ex.yaml") or_else panic("read file error!")
    tokens := lexer.tokenize(data) or_else panic("tokenize error!")

    fmt.println(tokens)
}