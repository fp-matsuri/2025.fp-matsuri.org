module Site exposing
    ( config
    , eventName, eventName_2025, tagline
    , summaryLarge
    )

{-| <https://elm-pages.com/docs/file-structure#site.elm>

@docs config

@docs eventName, eventName_2025, tagline
@docs summaryLarge

-}

import BackendTask exposing (BackendTask)
import FatalError exposing (FatalError)
import Head
import Head.Seo exposing (Common)
import LanguageTag as LT
import LanguageTag.Language exposing (ja)
import LanguageTag.Region exposing (jp)
import Pages.Url
import SiteConfig exposing (SiteConfig)
import UrlPath


config : SiteConfig
config =
    { canonicalUrl = "https://2025.fp-matsuri.org"
    , head = head
    }


head : BackendTask FatalError (List Head.Tag)
head =
    [ Head.rootLanguage (LT.build LT.emptySubtags ja)
    , Head.metaName "viewport" (Head.raw "width=device-width,initial-scale=1")
    , Head.sitemapLink "/sitemap.xml"
    ]
        |> BackendTask.succeed


eventName : String
eventName =
    "関数型まつり"


eventName_2025 : String
eventName_2025 =
    eventName ++ " 2025"


tagline : String
tagline =
    "関数型まつりは関数型プログラミングをテーマとしたカンファレンスです"


summaryLarge : { pageTitle : String } -> Common
summaryLarge { pageTitle } =
    Head.Seo.summaryLarge
        { canonicalUrlOverride = Nothing
        , siteName = eventName
        , image =
            { url = [ "images", "summaryLarge.png" ] |> UrlPath.join |> Pages.Url.fromPath
            , alt = eventName_2025
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , description = tagline
        , locale = Just ( ja, jp )
        , title =
            if pageTitle /= "" then
                pageTitle ++ " | " ++ eventName

            else
                eventName
        }
