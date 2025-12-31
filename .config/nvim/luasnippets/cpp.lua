local ls = require('luasnip')
local s, i, fmt = ls.snippet, ls.insert_node, require('luasnip.extras.fmt').fmt

local cppsnippets = {}

local template = [=[#include <bits/stdc++.h>  // {{{{{{

#include <version>
#ifdef __cpp_lib_ranges_enumerate
#include <ranges>
namespace rv = std::views;
namespace rs = std::ranges;
#endif

#pragma GCC optimize("O2,unroll-loops")
#pragma GCC target("avx2,bmi,bmi2,lzcnt,popcnt")

using namespace std;

using i32 = int32_t;
using u32 = uint32_t;
using i64 = int64_t;
using u64 = uint64_t;
using f64 = double;
using f128 = long double;

#if __cplusplus >= 202002L
template <typename T>
constexpr T MIN = std::numeric_limits<T>::min();

template <typename T>
constexpr T MAX = std::numeric_limits<T>::max();
#endif

#ifdef LOCAL
#define db(...) std::print(__VA_ARGS__)
#define dbln(...) std::println(__VA_ARGS__)
#else
#define db(...)
#define dbln(...)
#endif
//  }}}}}}]=]

-- utility snippets
for _, snippet in ipairs({
    s('in', fmt('#include {}', { i(1) })),
    s(
        'main',
        fmt(
            [[#include <iostream>

int main() {{
  {}

  return 0;
}}]],
            { i(1) }
        )
    ),
    s('pr', fmt('std::cout << {}', { i(1) })),
    s('s', fmt('std::{}', { i(1) })),
    s(
        'pbds',
        fmt(
            [[
#include <ext/pb_ds/assoc_container.hpp>
#include <ext/pb_ds/tree_policy.hpp>

namespace pbds = __gnu_pbds;

template <class T>
using hashset = pbds::gp_hash_table<T, pbds::null_type>;

template <class K, class V>
using hashmap = pbds::gp_hash_table<K, V>;

template <class K, class V>
using multitreemap =
    pbds::tree<K, V, less_equal<K>, pbds::rb_tree_tag,
               pbds::tree_order_statistics_node_update>;

template <class T>
using treeset =
    pbds::tree<T, pbds::null_type, less<T>, pbds::rb_tree_tag,
               pbds::tree_order_statistics_node_update>;

template <class K, class V>
using treemap =
    pbds::tree<K, V, less<K>, pbds::rb_tree_tag,
               pbds::tree_order_statistics_node_update>;

template <class T>
using treemultiset =
    pbds::tree<T, pbds::null_type, less_equal<T>, pbds::rb_tree_tag,
               pbds::tree_order_statistics_node_update>;
    ]],
            {}
        )
    ),
}) do
    table.insert(cppsnippets, snippet)
end

for _, entry in ipairs({
    {
        trig = 'codeforces',
        body = template .. [[


void solve() {{
  {}
}}

int main() {{  // {{{{{{
  std::cin.exceptions(std::cin.failbit);
#ifdef LOCAL
  std::cerr.rdbuf(std::cout.rdbuf());
  std::cout.setf(std::ios::unitbuf);
  std::cerr.setf(std::ios::unitbuf);
#else
  std::cin.tie(nullptr)->sync_with_stdio(false);
#endif
  u32 tc = 1;
  std::cin >> tc;
  for (u32 t = 0; t < tc; ++t) {{
    solve();
  }}
  return 0;
}}  // vim: set foldmethod=marker foldmarker={{{{{{,}}}}}}]],
    },
    {
        trig = 'atcoder',
        body = template .. [[


void solve() {{
  {}
}}

int main() {{  // {{{{{{
  std::cin.exceptions(std::cin.failbit);
#ifdef LOCAL
  std::cerr.rdbuf(std::cout.rdbuf());
  std::cout.setf(std::ios::unitbuf);
  std::cerr.setf(std::ios::unitbuf);
#else
  std::cin.tie(nullptr)->sync_with_stdio(false);
#endif
  solve();
  return 0;
}}  // vim: set foldmethod=marker foldmarker={{{{{{,}}}}}}]],
    },
    {
        trig = 'cses',
        body = template .. [[


void solve() {{
  {}
}}

int main() {{  // {{{{{{
  std::cin.exceptions(std::cin.failbit);
#ifdef LOCAL
  std::cerr.rdbuf(std::cout.rdbuf());
  std::cout.setf(std::ios::unitbuf);
  std::cerr.setf(std::ios::unitbuf);
#else
  std::cin.tie(nullptr)->sync_with_stdio(false);
#endif
  solve();
  return 0;
}}  // vim: set foldmethod=marker foldmarker={{{{{{,}}}}}}]],
    },
}) do
    table.insert(cppsnippets, s(entry.trig, fmt(entry.body, { i(1) })))
end

return cppsnippets
