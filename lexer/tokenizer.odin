package lexer

import "core:fmt"
import "core:strings"

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
    Sequence_Item,// -
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

Token :: union {
    Token_Type, string
}

Tokenizer :: struct {
    data: string,
    pos: Position,
    tokens: [dynamic]Token,
}

tokenizer_init :: proc(t: ^Tokenizer, input: string) {
    t.data = input
    t.pos = Position{}
    position_init(&t.pos, input)
    t.tokens = [dynamic]Token{}
}

tokenizer_parse :: proc(t: ^Tokenizer, allocator := context.allocator) -> ([]Token, Allocator_Error) {
    return t.tokens[:], nil
}