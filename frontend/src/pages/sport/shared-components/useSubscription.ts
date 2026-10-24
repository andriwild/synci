import {useState} from "react";
import {useDispatch} from "react-redux";
import {notification} from "antd";
import {syncConfigActions, useSyncConfig} from "../../../services/syncConfig/syncCofigSlice.ts";
import {syncConfigApi} from "../../../services/syncConfig/syncConfigApi.ts";
import {syncConfigDtoMapper} from "../../../services/syncConfig/helpers/syncConfigHelper.ts";
import {SyncConfigRequest} from "../../../services/syncConfig/entities/syncConfigDto.ts";
import {useUser} from "../../../services/user/UserSlice.ts";
import {stringifyApiError} from "../../../services/common/apiHelpers.ts";
import {SportEvent} from "../../../services/event/entities/event.ts";
import {Team} from "../../../services/team/entities/team.ts";
import {Matchup} from "../../../services/syncConfig/entities/syncConfig.ts";
import {SubscriptionType, track} from "../../../utils/analytics.ts";

/** Why subscribing is not possible right now; null when it is. */
export type SubscribeBlocker = "login" | "no-config" | null;

/**
 * Everything the detail page needs to add a sport, team, event or Top Event to the active subscription:
 * state checks, the update itself, tracking and error feedback. `pendingKey` identifies the
 * entry whose request is in flight, so only that button shows a spinner.
 */
export const useSubscription = () => {
    const user = useUser();
    const syncConfig = useSyncConfig();
    const dispatch = useDispatch();
    const [updateSyncConfig] = syncConfigApi.useUpdateMutation();
    const [api, contextHolder] = notification.useNotification();
    const [pendingKey, setPendingKey] = useState<string | null>(null);

    const blocker: SubscribeBlocker = !user ? "login" : !syncConfig?.id ? "no-config" : null;

    const isSportIncluded = (sportId: string) => syncConfig?.sports?.some((s) => s.id === sportId) ?? false;
    const isTeamIncluded = (teamId: string) => syncConfig?.teams?.some((t) => t.id === teamId) ?? false;
    const isEventIncluded = (eventId: string) => syncConfig?.events?.some((e) => e.id === eventId) ?? false;
    /** A – B and B – A are the same Top Event. */
    const isMatchupIncluded = (teamA: Team, teamB: Team) => syncConfig?.matchups?.some((m) =>
        m.sourceId === teamA.sourceId && [m.teamA.id, m.teamB.id].sort().join() === [teamA.id, teamB.id].sort().join()) ?? false;
    const matchups = syncConfig?.matchups ?? [];
    const matchupCount = matchups.length;
    const matchupLimit = syncConfig?.matchupLimit ?? 20;

    const update = async (
        key: string,
        change: (dto: SyncConfigRequest) => void,
        analytics: { type: SubscriptionType; name: string; sport?: string },
        event: "subscription-add" | "subscription-remove" = "subscription-add",
    ): Promise<boolean> => {
        if (!syncConfig || blocker) return false;
        const dto = syncConfigDtoMapper(syncConfig);
        change(dto);
        setPendingKey(key);
        try {
            const response = await updateSyncConfig(dto);
            if (response.error || !response.data) {
                api.error({
                    message: "Abo konnte nicht aktualisiert werden",
                    description: response.error ? stringifyApiError(response.error) : undefined,
                    placement: "bottomRight",
                });
                return false;
            }
            track(event, analytics);
            dispatch(syncConfigActions.setSyncConfig(response.data));
            return true;
        } finally {
            setPendingKey(null);
        }
    };

    return {
        contextHolder,
        blocker,
        pendingKey,
        isSportIncluded,
        isTeamIncluded,
        isEventIncluded,
        isMatchupIncluded,
        matchups,
        matchupCount,
        matchupLimit,
        addSport: (sportId: string, title: string) =>
            update(`sport:${sportId}`, (dto) => {
                dto.sports = [...(dto.sports ?? []), sportId];
            }, {type: "sport", name: title}),
        addTeam: (team: Team) =>
            update(`team:${team.id}`, (dto) => {
                dto.teams = [...(dto.teams ?? []), {id: team.id, sourceId: team.sourceId}];
            }, {type: "team", name: team.name, sport: team.rootSport}),
        addEvent: (event: SportEvent) =>
            update(`event:${event.id}`, (dto) => {
                dto.events = [...(dto.events ?? []), {id: event.id, sourceId: event.sourceId}];
            }, {type: "event", name: event.name, sport: event.rootSport}),
        addMatchup: (teamA: Team, teamB: Team, sport: string) =>
            update(`matchup:${teamA.id}:${teamB.id}`, (dto) => {
                dto.matchups = [...(dto.matchups ?? []), {sourceId: teamA.sourceId, teamAId: teamA.id, teamBId: teamB.id}];
            }, {type: "matchup", name: `${teamA.name} – ${teamB.name}`, sport}),
        removeMatchup: (matchup: Matchup) =>
            update(`matchup:${matchup.teamA.id}:${matchup.teamB.id}`, (dto) => {
                dto.matchups = dto.matchups?.filter((m) => m.teamAId !== matchup.teamA.id || m.teamBId !== matchup.teamB.id);
            }, {type: "matchup", name: `${matchup.teamA.name} – ${matchup.teamB.name}`, sport: matchup.rootSport}, "subscription-remove"),
    };
};

export type Subscription = ReturnType<typeof useSubscription>;
