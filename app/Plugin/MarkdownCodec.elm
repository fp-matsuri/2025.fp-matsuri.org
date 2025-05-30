module Plugin.MarkdownCodec exposing (Error(..), withFrontmatter)

{-| elm-pages のサンプルに使われている MarkdownCodec モジュールから、不使用コードを削除したもの
<https://github.com/dillonkearns/elm-pages/blob/master/plugins/MarkdownCodec.elm>
-}

import BackendTask exposing (BackendTask)
import BackendTask.File as StaticFile
import FatalError exposing (FatalError)
import Json.Decode exposing (Decoder)
import Markdown.Block exposing (Block)
import Markdown.Parser
import Markdown.Renderer


type Error
    = FileDoesNotExist
    | FileReadFailure String
    | FrontmatterDecodingFailure Json.Decode.Error
    | MarkdownProcessingFailure FatalError


withFrontmatter :
    (frontmatter -> List Block -> value)
    -> Decoder frontmatter
    -> Markdown.Renderer.Renderer view
    -> String
    -> BackendTask Error value
withFrontmatter constructor frontmatterDecoder_ renderer filePath =
    BackendTask.map2 constructor
        (StaticFile.onlyFrontmatter
            frontmatterDecoder_
            filePath
            |> BackendTask.mapError
                (\entryError ->
                    case entryError.recoverable of
                        StaticFile.FileDoesntExist ->
                            FileDoesNotExist

                        StaticFile.FileReadError msg ->
                            FileReadFailure msg

                        StaticFile.DecodingError decodeErr ->
                            FrontmatterDecodingFailure decodeErr
                )
        )
        (StaticFile.bodyWithoutFrontmatter
            filePath
            |> BackendTask.mapError
                (\entryError ->
                    case entryError.recoverable of
                        StaticFile.FileDoesntExist ->
                            FileDoesNotExist

                        StaticFile.FileReadError msg ->
                            FileReadFailure msg

                        StaticFile.DecodingError () ->
                            MarkdownProcessingFailure (FatalError.fromString "Unexpected decoding error in bodyWithoutFrontmatter")
                )
            |> BackendTask.andThen
                (\rawBody ->
                    rawBody
                        |> Markdown.Parser.parse
                        |> Result.mapError (\_ -> MarkdownProcessingFailure (FatalError.fromString "Couldn't parse markdown."))
                        |> BackendTask.fromResult
                )
            |> BackendTask.andThen
                (\blocks ->
                    blocks
                        |> Markdown.Renderer.render renderer
                        |> Result.map (\_ -> blocks)
                        |> Result.mapError (\errMsg -> MarkdownProcessingFailure (FatalError.fromString errMsg))
                        |> BackendTask.fromResult
                )
        )
