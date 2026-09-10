use crate::parser::*;
use matcher_macros::define_matcher;

define_matcher!(SystemVerilog {
    delimiters: [
        "begin" => "end",
        "module" => "endmodule",
        "function" => "endfunction",
        "task" => "endtask",
        "case" => "endcase",
        "if" => "endif"
    ],
    line_comment: ["//"],
    block_comment: ["/*" => "*/"],
    string: ["\""]
});
