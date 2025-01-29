module Site exposing (config, summaryLarge)

{-| <https://elm-pages.com/docs/file-structure#site.elm>
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


summaryLarge : { pageTitle : String } -> Common
summaryLarge { pageTitle } =
    Head.Seo.summaryLarge
        { canonicalUrlOverride = Nothing
        , siteName = "関数型まつり"
        , image =
            { url = [ "images", "summaryLarge.png" ] |> UrlPath.join |> Pages.Url.fromPath
            , alt = "関数型まつり 2025"
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , description = "関数型まつりは関数型プログラミングをテーマとしたカンファレンスです"
        , locale = Just ( ja, jp )
        , title =
            if pageTitle /= "" then
                pageTitle ++ " | 関数型まつり"

            else
                "関数型まつり"
        }
