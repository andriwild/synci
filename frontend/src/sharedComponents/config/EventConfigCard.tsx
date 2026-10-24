import {theme} from "antd";
import {IconCalendarEvent} from "@tabler/icons-react";
import {syncConfigApi} from "../../services/syncConfig/syncConfigApi.ts";
import {syncConfigActions, useSyncConfig} from "../../services/syncConfig/syncCofigSlice.ts";
import {syncConfigDtoMapper} from "../../services/syncConfig/helpers/syncConfigHelper.ts";
import {useDispatch} from "react-redux";
import {SportEvent} from "../../services/event/entities/event.ts";
import {convertToSwissDate} from "../../services/common/dateUtil.ts";
import {ConfigCardShell} from "./ConfigCardShell.tsx";
import {GameTitle} from "../GameTitle.tsx";
import {track} from "../../utils/analytics.ts";
import {SyncConfig} from "../../services/syncConfig/entities/syncConfig.ts";

export const EventConfigCard = ({event, config}: { event: SportEvent, config?: SyncConfig }) => {
    const [updateSyncConfig, updateSyncConfigStatus] = syncConfigApi.useUpdateMutation();
    const currentSyncConfig = useSyncConfig();
    const syncConfig = config ?? currentSyncConfig;
    const token = theme.useToken().token;
    const dispatch = useDispatch();

    const remove = async () => {
        if (!syncConfig || !syncConfig.id) {
            return;
        }
        const dto = syncConfigDtoMapper(syncConfig);
        dto.events = dto.events?.filter((e) => e.id !== event.id);
        const newSyncConfig = await updateSyncConfig(dto);
        if (newSyncConfig.data) {
            track("subscription-remove", {type: "event", name: event.name, sport: event.rootSport});
        }
        if (newSyncConfig.data && syncConfig.id === currentSyncConfig?.id) {
            dispatch(syncConfigActions.setSyncConfig(newSyncConfig.data));
        }
    };

    return (
        <ConfigCardShell
            icon={<IconCalendarEvent size={28} color={token.colorPrimary}/>}
            title={event.name}
            heading={event.teams && event.teams.length >= 2
                ? <GameTitle teams={event.teams} name={event.name} logoSize={20} strong/>
                : undefined}
            subtitle={[event.rootSport, convertToSwissDate(event.startsOn)].filter(Boolean).join(" · ")}
            tag="Event"
            onRemove={remove}
            loading={updateSyncConfigStatus.isLoading}
        />
    );
};
