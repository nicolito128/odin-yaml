package yaml

NodeKind :: enum {
    Scalar,
    Sequence,
    Mapping
}

ScalarType :: enum {
    Int,
    Float,
    Boolean,
    String,
    Null
}

QuotingType :: enum {
    None,
    Single,
    Doubles
}