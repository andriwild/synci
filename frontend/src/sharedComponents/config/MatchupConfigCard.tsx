import {syncConfigApi} from "../../services/syncConfig/syncConfigApi.ts";
import {syncConfigActions, useSyncConfig} from "../../services/syncConfig/syncCofigSlice.ts";
import {syncConfigDtoMapper} from "../../services/syncConfig/helpers/syncConfigHelper.ts";
import {useDispatch} from "react-redux";
import {Matchup, SyncConfig} from "../../services/syncConfig/entities/syncConfig.ts";
import {ConfigCardShell} from "./ConfigCardShell.tsx";
import {theme} from "antd";
import {IconTrophy} from "@tabler/icons-react";
import {GameTitle} from "../GameTitle.tsx";
import {track} from "../../utils/analytics.ts";

export const MatchupConfigCard = ({matchup, config}: { matchup: Matchup, config?: SyncConfig }) => {
    const [updateSyncConfig, updateSyncConfigStatus] = syncConfigApi.useUpdateMutation();
    const currentSyncConfig = useSyncConfig();
    const syncConfig = config ?? currentSyncConfig;
    const dispatch = useDispatch();
    const token = theme.useToken().token;
    const name = `${matchup.teamA.name} – ${matchup.teamB.name}`;

    const remove = async () => {
        if (!syncConfig || !syncConfig.id) {
            return;
        }
        const dto = syncConfigDtoMapper(syncConfig);
        dto.matchups = dto.matchups?.filter((m) => m.teamAId !== matchup.teamA.id || m.teamBId !== matchup.teamB.id);
        const newSyncConfig = await updateSyncConfig(dto);
        if (newSyncConfig.data) {
            track("subscription-remove", {type: "matchup", name, sport: matchup.rootSport});
        }
        if (newSyncConfig.data && syncConfig.id === currentSyncConfig?.id) {
            dispatch(syncConfigActions.setSyncConfig(newSyncConfig.data));
        }
    };

    return (
        <ConfigCardShell
            icon={<IconTrophy size={28} color={token.colorPrimary}/>}
            title={name}
            heading={<GameTitle teams={[matchup.teamA, matchup.teamB]} name={name} logoSize={20} strong/>}
            subtitle={matchup.rootSport}
            tag="Top Event"
            onRemove={remove}
            loading={updateSyncConfigStatus.isLoading}
        />
    );
};
