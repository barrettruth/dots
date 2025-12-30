return {
    s('/* ', fmt('/* {} */', { i(1) })),
    s('pr', fmt('printf("{}", {});', { i(1), i(2) })),
    s(
        'main',
        fmt(
            [[
                #include <stdio.h>

                int main(void) {{
                  {}

                  return 0;
                }}
            ]],
            { i(1) }
        )
    ),
}
