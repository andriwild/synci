import {theme} from "antd";
import {IconUsersGroup} from "@tabler/icons-react";
import {syncConfigApi} from "../../services/syncConfig/syncConfigApi.ts";
import {syncConfigActions, useSyncConfig} from "../../services/syncConfig/syncCofigSlice.ts";
import {syncConfigDtoMapper} from "../../services/syncConfig/helpers/syncConfigHelper.ts";
import {useDispatch} from "react-redux";
import {Team} from "../../services/team/entities/team.ts";
import {ConfigCardShell} from "./ConfigCardShell.tsx";
import {track} from "../../utils/analytics.ts";
import {SyncConfig} from "../../services/syncConfig/entities/syncConfig.ts";

export const TeamConfigCard = ({team, config}: { team: Team, config?: SyncConfig }) => {
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
        dto.teams = dto.teams?.filter((s) => s.id !== team.id);
        const newSyncConfig = await updateSyncConfig(dto);
        if (newSyncConfig.data) {
            track("subscription-remove", {type: "team", name: team.name, sport: team.rootSport});
        }
        if (newSyncConfig.data && syncConfig.id === currentSyncConfig?.id) {
            dispatch(syncConfigActions.setSyncConfig(newSyncConfig.data));
        }
    };

    return (
        <ConfigCardShell
            icon={<IconUsersGroup size={28} color={token.colorPrimary}/>}
            title={team.name}
            subtitle={team.rootSport}
            tag="Team"
            onRemove={remove}
            loading={updateSyncConfigStatus.isLoading}
        />
    );
};
