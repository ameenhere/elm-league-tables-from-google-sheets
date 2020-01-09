module Pages.LeagueList.View exposing (page)

import Element exposing (..)
import Element.Events exposing (onClick)
import Models.Config exposing (Config)
import Models.LeagueSummary exposing (LeagueSummary)
import Msg exposing (..)
import Pages.HeaderBar exposing (..)
import Pages.HeaderBarItem exposing (..)
import Pages.MaybeResponse exposing (..)
import Pages.Page exposing (..)
import Pages.Responsive exposing (..)
import Pages.ViewHelpers exposing (..)
import RemoteData exposing (WebData)
import Styles exposing (..)


page : Config -> WebData (List LeagueSummary) -> Responsive -> Styles-> Page
page config response responsive styles =
    Page
        (SingleHeader <|
            HeaderBar
                [ HeaderButtonSizedSpace ]
                config.applicationTitle
                [ RefreshHeaderButton RefreshLeagueList ]
        )
        (maybeResponse response <| leagueList responsive styles)


leagueList : Responsive -> Styles -> List LeagueSummary -> Element Msg
leagueList responsive styles leagueSummaries =
    column
        [ width fill
        , dataTestClass "leagues"
        ]
        (List.map (leagueTitle responsive styles) leagueSummaries)


leagueTitle : Responsive -> Styles -> LeagueSummary -> Element Msg
leagueTitle responsive styles league =
    Styles.elWithStyle
        styles.leagueListLeagueName
        [ padding responsive.mediumGap
        , spacing responsive.smallGap
        , width (fill |> maximum responsive.designPortraitWidth)
        , dataTestClass "league"
        , centerX
        , onClick <| ShowLeagueTable league.title
        ]
        (paragraph [] [ text league.title ])
