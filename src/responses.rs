use httpageboy::{Response, StatusCode};
use serde::Serialize;
use serde_json::Value;

pub(crate) fn response_with_body(
  status_code: StatusCode,
  content_type: &str,
  body: Vec<u8>,
) -> Response {
  Response {
    status: status_code.to_string(),
    headers: vec![("Content-Type".to_string(), content_type.to_string())],
    body,
  }
}

pub(crate) fn json_response_bytes(status_code: StatusCode, body: Vec<u8>) -> Response {
  response_with_body(status_code, "application/json", body)
}

pub(crate) fn json_response_value(status_code: StatusCode, value: Value) -> Response {
  json_response_bytes(status_code, value.to_string().into_bytes())
}

pub(crate) fn json_response<T: Serialize>(status_code: StatusCode, value: &T) -> Response {
  json_response_bytes(status_code, serde_json::to_vec(value).unwrap())
}
