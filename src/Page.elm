module Page exposing
    ( Page, Metadata
    , pagesGlob, allMetadata
    , frontmatterDecoder
    )

{-| サイト内のページを表す型と、関数を提供するモジュール

@docs Page, Metadata
@docs pagesGlob, allMetadata
@docs frontmatterDecoder

-}

import BackendTask
import BackendTask.File as File
import BackendTask.Glob as Glob
import FatalError exposing (FatalError)
import Json.Decode as Decode exposing (Decoder)
import Route


type alias Page =
    { filePath : String
    , slug : String
    }


{-| content/ 直下にあるMarkdownファイルを取得するためのBackendTask
-}
pagesGlob : BackendTask.BackendTask error (List Page)
pagesGlob =
    Glob.succeed Page
        |> Glob.captureFilePath
        |> Glob.match (Glob.literal "content/")
        |> Glob.capture Glob.wildcard
        |> Glob.match (Glob.literal ".md")
        |> Glob.toBackendTask


{-| content/ 直下にあるMarkdownファイルのMetadataを取得するためのBackendTask
-}
allMetadata :
    BackendTask.BackendTask
        { fatal : FatalError, recoverable : File.FileReadError Decode.Error }
        (List ( Route.Route, Metadata ))
allMetadata =
    pagesGlob
        |> BackendTask.map
            (\paths ->
                paths
                    |> List.map
                        (\{ filePath, slug } ->
                            BackendTask.map2 Tuple.pair
                                (BackendTask.succeed <| Route.Slug_ { slug = slug })
                                (File.onlyFrontmatter frontmatterDecoder filePath)
                        )
            )
        |> BackendTask.resolve
        |> BackendTask.map
            (\articles ->
                articles
                    |> List.filterMap
                        (\( route, metadata ) ->
                            Just ( route, metadata )
                        )
            )


{-| Markdownファイルの Frontmatter に記述された情報を格納するための型
2025年2月時点では、title のみが含まれます
-}
type alias Metadata =
    { title : String }


frontmatterDecoder : Decoder Metadata
frontmatterDecoder =
    Decode.map Metadata
        (Decode.field "title" Decode.string)
