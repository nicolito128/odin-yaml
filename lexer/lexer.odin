package lexer

import "core:fmt"
import "core:os"
import "core:strings"
import "core:text/scanner"
import "core:mem"
import "core:io"

OS_Error :: os.Error
Allocator_Error :: mem.Allocator_Error
IO_Error :: io.Error

Error :: union {
    OS_Error,
    Allocator_Error,
    IO_Error,
}

Token_Type :: enum u8 {
    // YAML Document
    Directive, // %
    Document_Header, // ---
    Document_Terminator, // ...

    // Keys
    Identifier, // <identifier> : ...
    Colon, // :

    // Values
    // Ex. Hello, "1.0.0", 'Lorem ipsum...', 2.76, true, FALSE
    Literal, // ... : <literal>
    Literal_Block_Scalar, // |
    Folded_Block_Scalar, // >

    // Flow
    Whitespace, // spaces and tabs
    New_Line, // \n
    Comma, // ,

    // YAML hashmaps
    Map_Start,
    Map_End,

    // YAML lists
    Sequence_Start,
    Sequence_End,

    // JSON-like objects: { item1: value1, item2: value2, ... }
    Object_Start,
    Object_End,

    // JSON-like arrays: [ item 1, item 2, item 3, ...]
    Array_Start,
    Array_End,
    
    // Documentation
    Comment, // # <text> <end_of_line>

    // End Of FilE
    EOF,
}

Lexer_Token :: union {
    Token_Type, string
}

read_file :: proc(filepath: string, allocator := context.allocator) -> (data: string, err: OS_Error) {
	s := os.read_entire_file_from_filename_or_err(filepath, allocator) or_return
    data = string(s)
	return
}

tokenize :: proc(data: string, allocator := context.allocator) -> (t: []Lexer_Token, err: Error) {
    tokens: [dynamic]Lexer_Token
    defer delete(data)

    b: strings.Builder
    make_empty_builder(&b) or_return
    defer strings.builder_destroy(&b)

    offset := 0; line := 0; ch: rune
    for offset < len(data) {
        if err != nil {
            return t, err
        }
        ch = cast(rune)data[offset]

        switch ch {
        case '\n':
            line += 1

            append_elem(&tokens, Token_Type.New_Line)
        }

        strings.write_rune(&b, ch) or_return

        offset += 1
        if offset == len(data) {
            dump_builder_as(&b, &tokens, Token_Type.Literal)
        }
    }

    append_elem(&tokens, Token_Type.EOF)
    t = tokens[:]
    return t, nil
}

make_empty_builder :: proc(b: ^strings.Builder, allocator := context.allocator) -> Allocator_Error {
    b^ = strings.builder_make_none() or_return
    return nil
}

clear_builder :: proc(b: ^strings.Builder, allocator := context.allocator) -> (str: string, err: Allocator_Error) {
    str, err = strings.clone(strings.to_string(b^))
    strings.builder_destroy(b)
    return str, nil
}

move_position :: proc(cur_pos: ^int, steps: int) {
    cur_pos^ += steps
}

// seek_delim searches for a slice with the specified delimiter and returns the count steps and the slice from start to start+n.
seek_delim :: proc(str: string, start: int, delim: rune) -> (n: int, s: string) {
    n = start
    for n < len(str) {
        c := cast(rune)str[n]
        if c == delim {
            break
        }
        n += 1
    }
    return n - start, str[start:n]
}

// seek_delim_clone does the same as seek_delim but the returned string is a clone of the original.
seek_delim_clone :: proc(str: string, start: int, delim: rune, allocator := context.allocator) -> (n: int, s: string) {
    n, s = seek_delim(str, start, delim)
    return n, strings.clone(s)
}

check_next_rune :: proc(str: string, pos: int, tok: rune) -> (ok: bool) {
    if (pos+1) < len(str) {
        ok = cast(rune)str[pos+1] == tok
    }
    return ok
}

dump_string_as :: proc(s: string, tokens: ^[dynamic]Lexer_Token, tok: Lexer_Token) -> (err: Allocator_Error) {
    append_elem(tokens, tok) or_return
    append_elem(tokens, s) or_return
    return nil
}

dump_builder_as :: proc(b: ^strings.Builder, tokens: ^[dynamic]Lexer_Token, tok: Lexer_Token, allocator := context.allocator) -> (err: Allocator_Error) {
    if strings.builder_len(b^) > 0 {
        str := clear_builder(b) or_return
        dump_string_as(str, tokens, tok) or_return
    }
    return nil
}