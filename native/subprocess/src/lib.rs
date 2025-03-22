use std::{io::{Read, Write}, process::{Command, Stdio}};

use rustler::{Binary, Encoder, SerdeTerm};
use serde::{Deserialize, Serialize};

#[derive(Debug, Deserialize, Serialize)]
#[serde(rename = "Elixir.Subprocess.ProcessResult")]
struct ProcessResult {
    status: Option<i32>,
    stdout: Vec<u8>,
    stderr: Vec<u8>,
}

#[rustler::nif]
fn exiftool_json(image_data: Binary) -> impl Encoder {
    let mut child = Command::new("exiftool")
        // exif doesn’t really have timezones <https://photo.stackexchange.com/a/96714>
        .args(["-j", "-dateFormat", "%FT%T", "--", "-"])
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .spawn()
        .expect("spawn failed");
    let stdin = child.stdin.as_mut().expect("guaranteed by Command build");
    stdin.write_all(image_data.as_slice()).expect("write failed");
    let status = child.wait().expect("wait failed");
    let mut stdout = vec![];
    let mut stderr = vec![];
    child.stdout.expect("guaranteed by Command build").read_to_end(&mut stdout).expect("read from stdout failed");
    child.stderr.expect("guaranteed by Command build").read_to_end(&mut stderr).expect("read from stderr failed");

    SerdeTerm(ProcessResult {
        status: status.code(),
        // FIXME: this gets encoded as a charlist, which is unicode only and also a linked list :(
        stdout: stdout,
        // FIXME: this gets encoded as a charlist, which is unicode only and also a linked list :(
        // <https://github.com/rusterlium/rustler/issues/551>
        // <https://github.com/rusterlium/rustler/issues/668>
        stderr: stderr,
    })
}

rustler::init!("Elixir.Subprocess");
