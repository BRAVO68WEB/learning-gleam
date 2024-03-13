import dot_env
import dot_env/env
import pprint
import falcon.{type FalconResponse}
import falcon/core.{Json, Url}
import gleeunit/should
import gleam/dynamic
import gleam/result
import gleam/string

pub type PartialProfile {
  PartialProfile(login: String, hireable: Bool)
}

pub fn main() {
  dot_env.load()

  let profiledata =
    dynamic.decode2(
      PartialProfile,
      dynamic.field("login", dynamic.string),
      dynamic.field("hireable", dynamic.bool),
    )

  let username =
    env.get("USER")
    |> result.unwrap("NOT SET")

  let client =
    falcon.new(
      base_url: Url("https://api.github.com"),
      headers: [],
      timeout: falcon.default_timeout,
    )

  let resdata =
    client
    |> falcon.get(
      string.concat(["/users/", username]),
      expecting: Json(profiledata),
      options: [],
    )
    |> should.be_ok
    |> fn(res: FalconResponse(PartialProfile)) { res.body }

  let isforhire = resdata.hireable

  case isforhire {
    True -> pprint.debug("He is forhire")
    False -> pprint.debug("He is not forhire")
  }
}
