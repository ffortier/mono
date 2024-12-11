eav(1000, category-name, 'Looks').
eav(1000, category-color, '9a66fe').

eav(1001, block-name, 'say').
eav(1001, block-category, 1000).
eav(1001, block-arity, 1).
eav(1001, block-format, "say ~s").
eav(1001, block-type, instruction).

eav(1002, block-name, 'say-for').
eav(1002, block-category, 1000).
eav(1002, block-arity, 2).
eav(1002, block-format, "say ~s for ~f seconds").
eav(1002, block-type, instruction).
