package lexer

import "core:os"
import "core:strings"

read_file :: proc(filepath: string, allocator := context.allocator) -> (data: string, err: OS_Error) {
	s := os.read_entire_file_from_filename_or_err(filepath, allocator) or_return
    data = string(s)
	return
}

// seek_delim searches for a slice with the specified delimiter and returns the count steps and the slice from start to start+n.
seek_delim :: proc(s: string, start: int, delim: rune) -> (int, string) {
    n := start
    for n < len(s) {
        c := cast(rune)s[n]
        if c == delim {
            break
        }
        n += 1
    }
    return n - start, s[start:n]
}

// seek_delim_clone does the same as seek_delim but the returned string is a clone of the original.
seek_delim_clone :: proc(s: string, start: int, delim: rune, allocator := context.allocator) -> (int, string) {
    n, s := seek_delim(s, start, delim)
    return n, strings.clone(s)
}