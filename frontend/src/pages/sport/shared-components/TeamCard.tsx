import {Button, Flex, theme, Typography} from "antd";
import {displayGender, Team} from "../../../services/team/entities/team.ts";
import {track} from "../../../utils/analytics.ts";
import {IconCalendarPlus, IconUsersGroup} from "@tabler/icons-react";
import {useDispatch} from "react-redux";
import {syncConfigDtoMapper} from "../../../services/syncConfig/helpers/syncConfigHelper.ts";
import {syncConfigActions, useSyncConfig} from "../../../services/syncConfig/syncCofigSlice.ts";
import {syncConfigApi} from "../../../services/syncConfig/syncConfigApi.ts";
import {useUser} from "../../../services/user/UserSlice.ts";

export const TeamCard = ({team}: { team: Team }) => {
    const token = theme.useToken().token;
    const dispatch = useDispatch();
    const syncConfig = useSyncConfig();
    const [updateSyncConfig, updateSyncConfigStatus] = syncConfigApi.useUpdateMutation();
    const user = useUser();
    const alreadyIncluded = syncConfig?.teams.some((t) => t.id === team.id) ?? false;

    return (
        <Flex
            vertical
            gap={20}
            align={"center"}
            justify={"center"}
            style={{
                background: token.colorBgContainer,
                borderRadius: "20px",
                padding: "16px",
                minWidth: 0,
            }}
        >
            <IconUsersGroup size={30}/>
            <Typography.Text style={{textAlign: "center", overflowWrap: "anywhere"}}>{team.name} {displayGender(team.gender)}</Typography.Text>
            <Button
                disabled={!user || alreadyIncluded}
                style={{width: "100%"}}
                icon={<IconCalendarPlus size={20}/>}
                onClick={async () => {
                    if (!syncConfig || !syncConfig.id) {
                        return;
                    }
                    const dto = syncConfigDtoMapper(syncConfig);
                    dto.teams = [...(dto.teams ?? []), {id: team.id, sourceId: team.sourceId}];
                    const response = await updateSyncConfig(dto);
                    if (response.data) {
                        track("subscription-add", {type: "team", name: team.name, sport: team.rootSport});
                        dispatch(syncConfigActions.setSyncConfig(response.data));
                    }
                }}
                loading={updateSyncConfigStatus.isLoading}
                type="primary">Hinzufügen</Button>
        </Flex>
    );
}