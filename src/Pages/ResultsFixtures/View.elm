module Pages.ResultsFixtures.View exposing (page)

import Element exposing (..)
import Element.Attributes exposing (..)
import RemoteData exposing (WebData)
import Http exposing (decodeUri)

import Date exposing (..)
import Date.Extra exposing (..)
import Pages.Progressive exposing (..)
import LeagueStyleElements exposing (..)
import Msg exposing (..)
import Models.LeagueGamesForDay exposing (LeagueGamesForDay)
import Models.Game exposing (Game)
import Models.ResultsFixtures exposing (ResultsFixtures)
import Pages.MaybeResponse exposing (..)
import Pages.Page exposing (..)
import Pages.HeaderBar exposing (..) 
import Pages.HeaderBarItem exposing (..)


page : String -> WebData ResultsFixtures -> Device -> Page
page leagueTitle response device =
    Page
        ( DoubleHeader  
            (headerBar leagueTitle)
            (SubHeaderBar "Results / Fixtures"))
        ( maybeResponse response (fixturesResultsElement device) )

headerBar: String -> HeaderBar
headerBar leagueTitle = 
    HeaderBar 
        [ BackHeaderButton <| IndividualSheetRequest leagueTitle ] 
        (Maybe.withDefault "" (decodeUri leagueTitle))
        [ RefreshHeaderButton <| IndividualSheetRequestForResultsFixtures leagueTitle ]

fixturesResultsElement : Device -> ResultsFixtures -> Element Styles variation Msg
fixturesResultsElement device resultsFixtures =
    let
        progressive = calculateProgressive device
    in
        column 
            None 
            [ class "data-test-dates", width <| percent 100, center ]
            (List.map (day device progressive) resultsFixtures.days)

day : Device -> Progressive -> LeagueGamesForDay -> Element Styles variation Msg
day device progressive leagueGamesForDay =
    column 
        None 
        [ padding progressive.medium
        , spacing progressive.small
        , dayWidth progressive
        , class <| "data-test-day data-test-date-" ++ (dateClassNamePart leagueGamesForDay.date)
        ]
        [ dayHeader leagueGamesForDay.date
        , dayResultsFixtures device progressive leagueGamesForDay
        ] 

dayHeader : Maybe Date -> Element Styles variation Msg
dayHeader maybeDate =
    el 
        ResultFixtureDayHeader 
        [ class "data-test-dayHeader" ] 
        (text <| dateDisplay maybeDate)

dayResultsFixtures : Device -> Progressive -> LeagueGamesForDay -> Element Styles variation Msg
dayResultsFixtures device progressive leagueGamesForDay =
    column 
        None 
        [ width <| percent 100 ]
        (List.map (gameRow device progressive) leagueGamesForDay.games)

gameRow : Device -> Progressive -> Game -> Element Styles variation Msg
gameRow device progressive game =
    row 
        ResultFixtureRow 
        [ padding progressive.medium
        , spacing progressive.medium
        , center
        , class "data-test-game"
        , width <| percent 100 ] 
        [ 
            paragraph 
                ResultFixtureHome 
                [ alignRight, teamWidth device, class "data-test-homeTeamName" ] 
                [ text game.homeTeamName ]
            , row 
                None 
                [ ] 
                ( scoreSlashTime game )
            , paragraph 
                ResultFixtureAway 
                [ alignLeft, teamWidth device, class "data-test-awayTeamName" ] 
                [ text game.awayTeamName ]
        ]

scoreSlashTime : Game -> List (Element Styles variation Msg)
scoreSlashTime game =
    case (game.homeTeamGoals, game.awayTeamGoals) of
        (Just homeTeamGoals, Just awayTeamGoals) ->
            [ 
                el 
                    ResultFixtureScore 
                    [ alignRight, class "data-test-homeTeamGoals" ] 
                    (text <| toString homeTeamGoals)
                , el 
                    ResultFixtureScore 
                    [ ] 
                    (text " - ")
                , el 
                    ResultFixtureScore 
                    [ alignLeft, class "data-test-awayTeamGoals" ] 
                    (text <| toString awayTeamGoals)
            ]
        (_, _) ->
            [ 
                el 
                    ResultFixtureTime 
                    [ verticalCenter, class "data-test-datePlayed" ] 
                    (text <| timeDisplay game.datePlayed)
            ]
            
dateClassNamePart: Maybe Date -> String
dateClassNamePart maybeDate = 
    maybeDate
    |> Maybe.map (Date.Extra.toFormattedString "yyyy-MM-dd") 
    |> Maybe.withDefault "unscheduled"

dateDisplay: Maybe Date -> String
dateDisplay maybeDate = 
    maybeDate
    |> Maybe.map (Date.Extra.toFormattedString "MMMM d, yyyy") 
    |> Maybe.withDefault "Unscheduled"

timeDisplay: Maybe Date -> String
timeDisplay maybeDate = 
    maybeDate
    |> Maybe.map (Date.Extra.toFormattedString "HH:mm")
    |> Maybe.withDefault " - "

dayWidth: Progressive -> Element.Attribute variation msg
dayWidth progressive = 
    if progressive.designTeamWidth * 2.5 < progressive.viewportWidth * 0.8 then 
        width <| percent 100
    else 
        width <| percent 80
    
teamWidth: Device -> Element.Attribute variation msg
teamWidth device = 
    width <| fillPortion 50