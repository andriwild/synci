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
import {SubscriptionType, track} from "../../../utils/analytics.ts";

/** Why subscribing is not possible right now; null when it is. */
export type SubscribeBlocker = "login" | "no-config" | null;

/**
 * Everything the detail page needs to add a sport, team or event to the active subscription:
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

    const update = async (
        key: string,
        change: (dto: SyncConfigRequest) => void,
        analytics: { type: SubscriptionType; name: string; sport?: string },
    ) => {
        if (!syncConfig || blocker) return;
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
                return;
            }
            track("subscription-add", analytics);
            dispatch(syncConfigActions.setSyncConfig(response.data));
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
    };
};

export type Subscription = ReturnType<typeof useSubscription>;
