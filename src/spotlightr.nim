import std/asyncdispatch
from std/httpclient import newAsyncHttpClient, close, getContent
from std/json import parseJson, items, getStr, `[]`

from pkg/util/forStr import between

const ytRawVidApi = "https://api.spotlightr.com/video/getExternalSource?source=https://www.youtube.com/watch?v="

type
  SpotlightrVideoOption* = ref object
    url*, resolution*: string
  SpotlightrVideo* = seq[SpotlightrVideoOption]
    

proc rawVideo*(videoUrl: string): Future[SpotlightrVideo] {.async.} =
  ## Returns the raw video URL of Spotlightr video
  let client = newAsyncHttpClient "Mozilla/5.0 (X11; Linux x86_64; rv:102.0) Gecko/20100101 Firefox/102.0"
  let
    html = await client.getContent videoUrl
    ytCode = html.between("youtube.com/vi/", "/maxresdefault")

  let json = parseJson await client.getContent ytRawVidApi & ytCode
  close client

  for video in json["optimizedUrls"]:
    let vid = new SpotlightrVideoOption
    vid.url = video["url"].getStr
    vid.resolution = video["res"].getStr
    result.add vid

when isMainModule:
  for vid in waitFor rawVideo "https://renatameins.cdn.spotlightr.com/watch/MTI2NzAxNg":
    echo vid[]
