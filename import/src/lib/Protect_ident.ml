(*
   Change the name of identifiers that would make unsuitable Reason
   identifiers.
*)

(*
   Map from input identifier to output identifier and vice-versa.
   This map is initialized with the reserved keywords of the output language
   (Reason), and then filled with identifiers as they are encountered
   in the program.
*)
type t = {
  forward: (string, string) Hashtbl.t;
  backward: (string, string) Hashtbl.t;
}

(* All English keywords that can't be used as type names in Reason.

   Taken from the Reason sources at
   https://github.com/facebook/reason/blob/master/src/reason-parser/reason_declarative_lexer.mll#L85-L144
*)
let reason_keywords = [
  "and";
  "as";
  "assert";
  "begin";
  "class";
  "constraint";
  "do";
  "done";
  "downto";
  "else";
  "end";
  "exception";
  "external";
  "false";
  "for";
  "fun";
  "esfun";
  "function";
  "functor";
  "if";
  "in";
  "include";
  "inherit";
  "initializer";
  "lazy";
  "let";
  "switch";
  "module";
  "pub";
  "mutable";
  "new";
  "nonrec";
  "object";
  "of";
  "open";
  "or";
  "pri";
  "rec";
  "sig";
  "struct";
  "then";
  "to";
  "true";
  "try";
  "type";
  "val";
  "virtual";
  "when";
  "while";
  "with";
  "mod";
  "land";
  "lor";
  "lxor";
  "lsl";
  "lsr";
  "asr";
]

type availability = Available | Taken | Mismatched

(* Check that a maps to b and b maps to a, either already or if we make them
   that way. *)
let check x a b =
  match Hashtbl.find_opt x.forward a, Hashtbl.find_opt x.backward b with
  | None, None -> Available
  | Some b', Some a' when a = a' && b = b' -> Taken
  | _ -> Mismatched

let force_add x a b =
  Hashtbl.replace x.forward a b;
  Hashtbl.replace x.backward b a

let create ?(reserved = reason_keywords) () =
  let x = {
    forward = Hashtbl.create 100;
    backward = Hashtbl.create 100;
  } in
  List.iter (fun kw -> force_add x kw (kw ^ "_")) reserved;
  x

(* Try these suffixes first before falling back to random numbers. *)
let good_suffixes = [
  "";
  "_";
  "0"; "1"; "2"; "3"; "4"; "5";
]

let find_available x ident =
  let rec try_suffix suffixes =
    let candidate_suffix, suffixes =
      match suffixes with
      | [] -> (Random.bits () |> string_of_int), []
      | x :: xs -> x, xs
    in
    let ident' = ident ^ candidate_suffix in
    match check x ident ident' with
    | Taken -> assert false
    | Available ->
        force_add x ident ident';
        ident'
    | Mismatched ->
        try_suffix suffixes
  in
  try_suffix good_suffixes

(*
   Forward translation of an identifier. For example, "object" returns
   "object_". "object_" might then return something like "object_1".

   TODO: ensure that that the translated identifier is syntactically valid
         in Reason.
*)
let translate x ident =
  match Hashtbl.find_opt x.forward ident with
  | Some ident' -> ident'
  | None -> find_available x ident

(* TODO: tests *)
