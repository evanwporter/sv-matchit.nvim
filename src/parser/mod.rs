pub mod languages;
pub mod matcher;
pub mod parse;

pub use matcher::{Kind, Match, MatchWithLine, Matcher, Token};
pub use parse::{CharPos, State, parse};

use crate::buffer::ParsedBuffer;

const FILETYPES: &[&str] = &["systemverilog", "verilog"];

pub fn supports_filetype(filetype: &str) -> bool {
    FILETYPES.contains(&filetype)
}

pub fn parse_filetype(
    filetype: &str,
    lines: &[&str],
    initial_state: State,
) -> Option<ParsedBuffer> {
    match filetype {
        "systemverilog" | "verilog" => Some(parse(lines, initial_state, languages::SystemVerilog {})),
        _ => None,
    }
}
