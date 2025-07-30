import {Button, Flex, theme, Typography} from "antd";
import {Team} from "../../../services/team/entities/team.ts";
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

    return (
        <Flex
            vertical
            gap={20}
            align={"center"}
            justify={"center"}
            flex={1}
            style={{
                background: token.colorBgContainer,
                borderRadius: "20px",
                padding: "20px",
                minWidth: "200px",
            }}
        >
            <IconUsersGroup size={30}/>
            <Typography.Text>{team.name}</Typography.Text>
            <Button
                disabled={!user}
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
                }}
                loading={updateSyncConfigStatus.isLoading}
                type="primary">Hinzufügen</Button>
        </Flex>
    );
}