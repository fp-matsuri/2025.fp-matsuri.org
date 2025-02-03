module Page exposing
    ( Page, Metadata
    , frontmatterDecoder
    , allMetadata, pagesGlob
    )

{-|

@docs Page, Metadata
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


pagesGlob : BackendTask.BackendTask error (List Page)
pagesGlob =
    Glob.succeed Page
        |> Glob.captureFilePath
        |> Glob.match (Glob.literal "content/")
        |> Glob.capture Glob.wildcard
        |> Glob.match (Glob.literal ".md")
        |> Glob.toBackendTask


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


{-| Frontmatter部分をデコードし、 ArticleMetadata 型にする
-}
frontmatterDecoder : Decoder Metadata
frontmatterDecoder =
    Decode.map Metadata
        (Decode.field "title" Decode.string)
