# zig-ulid

ULIDs are
- 128-bit compatibility with UUID 1.21e+24 unique ULIDs per millisecond
    Lexicographically sortable!
- Canonically encoded as a 26 character string, as opposed to the 36 character UUID
- Uses Crockford's base32 for better efficiency and readability (5 bits per character)
- Case insensitive
- No special characters (URL safe)
- Monotonic sort order (correctly detects and handles the same millisecond)

See the full spec [here](https://github.com/ulid/spec).

This repo intends to implement the spec in Zig.

## TODO
- [ ] Monotonic ULID support


## Use
See [`example.zig`]() for usage examples.

```zig
const Ulid = @import("./ulid.zig");

// with passed in allocator; caller owns returned bytes
var ulid = try Ulid.ulidAllocNow(allocator);
// returns something like 01EHWMX9NA2P3ERBR5ESV5E3QP

// with buffer passed in
var ulid: [26]u8 = undefined;
try Ulid.ulidNow(&ulid);

// custom seed time with allocator
var ulid = try Ulid.ulidAlloc(allocator, 273);
// returns something like 000000008HMKR2RRN4VY1D3X2H

// custom seed time without allocator
try Ulid.ulid(&ulid, 273);
```

## License
MIT

