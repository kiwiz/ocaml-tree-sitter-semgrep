/* Auto-generated by codegen_type */
type assignment_statement = (variable, string, expression, string)
and comment = string
and expression = Intermediate_type1(variable) | Intermediate_type2(number) | Intermediate_type3((expression, string, expression)) | Intermediate_type4((expression, string, expression)) | Intermediate_type5((expression, string, expression)) | Intermediate_type6((expression, string, expression)) | Intermediate_type7((expression, string, expression))
and expression_statement = (expression, string)
and intermediate1 = Intermediate_type8(assignment_statement) | Intermediate_type9(expression_statement)
and number = string
and program = list(intermediate1)
and variable = string;