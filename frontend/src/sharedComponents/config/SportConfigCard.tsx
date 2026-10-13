import {Sport} from "../../services/sport/entities/sport.ts";
import {theme} from "antd";
import {IconBuildingCommunity, IconSitemap} from "@tabler/icons-react";
import {syncConfigApi} from "../../services/syncConfig/syncConfigApi.ts";
import {syncConfigActions, useSyncConfig} from "../../services/syncConfig/syncCofigSlice.ts";
import {syncConfigDtoMapper} from "../../services/syncConfig/helpers/syncConfigHelper.ts";
import {useDispatch} from "react-redux";
import {ConfigCardShell} from "./ConfigCardShell.tsx";
import {track} from "../../utils/analytics.ts";
import {SyncConfig} from "../../services/syncConfig/entities/syncConfig.ts";

export const SportConfigCard = ({sport, config}: { sport: Sport, config?: SyncConfig }) => {
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
        dto.sports = dto.sports?.filter((s) => s !== sport.id);
        const newSyncConfig = await updateSyncConfig(dto);
        if (newSyncConfig.data) {
            track("subscription-remove", {type: "sport", name: sport.label, sport: sport.rootSport});
        }
        if (newSyncConfig.data && syncConfig.id === currentSyncConfig?.id) {
            dispatch(syncConfigActions.setSyncConfig(newSyncConfig.data));
        }
    };

    return (
        <ConfigCardShell
            icon={sport.organisationId
                ? <IconBuildingCommunity size={28} color={token.colorPrimary}/>
                : <IconSitemap size={28} color={token.colorPrimary}/>}
            title={sport.label}
            subtitle={sport.rootSport && sport.rootSport !== sport.label ? sport.rootSport : undefined}
            tag={sport.organisationId ? "Organisation" : "Sportart"}
            onRemove={remove}
            loading={updateSyncConfigStatus.isLoading}
        />
    );
};
