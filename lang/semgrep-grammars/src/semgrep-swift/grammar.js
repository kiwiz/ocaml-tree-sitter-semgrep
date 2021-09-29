/*
  semgrep-swift

  Extends the standard swift grammar with semgrep pattern constructs.
*/

const base_grammar = require("tree-sitter-swift/grammar");

module.exports = grammar(base_grammar, {
  name: "swift",

  // conflicts: ($, previous) => previous.concat([[$._statement, $._expression]]),

  /*
     Support for semgrep ellipsis ('...') and metavariables ('$FOO'),
     if they're not already part of the base grammar.
  */
  rules: {
    semgrep_ellipsis: ($) => "...",
    semgrep_deep_ellipsis: ($) => seq("<...", $._expression, "...>"),

    simple_identifier: ($, previous) =>
      choice(/\$[a-zA-Z_][a-zA-Z_0-9]*/, ...previous.members),

    _opaque_type: ($, previous) => choice(/\$[a-zA-Z_][a-zA-Z_0-9]*/, previous),

    _expression: ($, previous) =>
      choice(
        prec(999, $.semgrep_ellipsis),
        $.semgrep_deep_ellipsis,
        ...previous.members
      ),

    _statement: ($, previous) =>
      choice($.semgrep_ellipsis, ...previous.members),

    _function_value_parameter: ($, previous) =>
      choice($.semgrep_ellipsis, previous),

    _class_member_declarations: ($, previous) =>
      choice($.semgrep_ellipsis, previous),
  },
});
