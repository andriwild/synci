import {Button, Flex, theme, Typography} from "antd";
import {displayGender, Team} from "../../../services/team/entities/team.ts";
import {IconCalendarPlus, IconUsersGroup} from "@tabler/icons-react";
import {useDispatch} from "react-redux";
import {syncConfigDtoMapper} from "../../../services/syncConfig/helpers/syncConfigHelper.ts";
import {syncConfigActions, useSyncConfig} from "../../../services/syncConfig/syncCofigSlice.ts";
import {syncConfigApi} from "../../../services/syncConfig/syncConfigApi.ts";
import {useUser} from "../../../services/user/UserSlice.ts";
import {track} from "../../../utils/analytics.ts";

export const TeamCard = ({team}: { team: Team }) => {
    const token = theme.useToken().token;
    const dispatch = useDispatch();
    const syncConfig = useSyncConfig();
    const [updateSyncConfig, updateSyncConfigStatus] = syncConfigApi.useUpdateMutation();
    const user = useUser();

    function syncConfigContainsTeam(team: Team): boolean {
         return syncConfig?.teams.some(t => t.id == team.id) || false;
    }

    return (
        <Flex
            vertical
            gap={10}
            align={"center"}
            justify={"space-between"}
            style={{
                background: token.colorBgContainer,
                borderRadius: "20px",
                padding: "10px",
            }}
        >
            <IconUsersGroup size={30}/>
            <Flex flex={1} align={"center"}>
                <Typography.Text style={{textAlign: "center"}}>{team.name} {displayGender(team.gender)}</Typography.Text>
            </Flex>
            <Button
                disabled={!user || syncConfigContainsTeam(team)}
                style={{width: "100%"}}
                icon={<IconCalendarPlus size={20}/>}
                onClick={async () => {
                    if (!syncConfig || !syncConfig.id) {
                        return;
                    }
                    const dto = syncConfigDtoMapper(syncConfig);
                    dto.teams = [...(dto.teams ?? []), {id: team.id, sourceId: team.sourceId}];
                    const response = await updateSyncConfig(dto);
                    dispatch(syncConfigActions.setSyncConfig(response.data));
                    if (response.data) {
                        track("subscription-add", {type: "team", name: team.name, sport: team.rootSport});
                    }
                }}
                loading={updateSyncConfigStatus.isLoading}
                type="primary">Hinzufügen</Button>
        </Flex>
    );
}
