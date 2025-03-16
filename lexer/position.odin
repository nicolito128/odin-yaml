package lexer

Position :: struct {
    buffer: string,
    col: int,
    row: int,
}

position_init :: proc(pos: ^Position, b: string) {
    pos.buffer = b
    position_reset(pos)
}

position_reset :: proc(pos: ^Position) {
    pos.col = 0
    pos.row = 0
}

position_advance :: proc(pos: ^Position, n: int) -> IO_Error {
    n: int = n
    for n > 0 && pos.col < len(pos.buffer) {
        if cast(rune)pos.buffer[pos.col] == '\n' {
            pos.row += 1
        }
        pos.col += 1
        n -= 1
        if n > 0 && pos.col >= len(pos.buffer) {
            return IO_Error.EOF
        }
    }
    return nil
}